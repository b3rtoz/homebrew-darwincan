class Darwincan < Formula
  desc "SocketCAN-style CAN bus access for macOS"
  homepage "https://github.com/b3rtoz/darwincan"
  url "https://github.com/b3rtoz/darwincan/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "fa375f735d3fd58a6f1d5234549593addd9603631c258aea424ac4f8aa199609"
  # The daemon is GPL-2.0-only; the libraries and the tools are MIT or Apache-2.0.
  license all_of: [
    "GPL-2.0-only",
    any_of: ["MIT", "Apache-2.0"],
  ]
  head "https://github.com/b3rtoz/darwincan.git", branch: "main"

  depends_on "rust" => :build
  depends_on :macos

  def install
    system "make", "install", "PREFIX=#{prefix}"
  end

  def caveats
    <<~EOS
      To start the daemon at login, register it as a launch agent for your user:
        darwincand install
      and remove it again with:
        darwincand uninstall

      After `brew upgrade darwincan`, restart the daemon so that it and the
      tools come from the same version:
        darwincand install

      The Python package is not part of this formula. It finds the C library
      installed here:
        pip install "git+https://github.com/b3rtoz/darwincan#subdirectory=python"
    EOS
  end

  test do
    # A Unix socket path may be about 100 bytes long at most.
    ENV["DARWINCAN_SOCKET"] = "#{testpath}/dc.sock"
    daemon = spawn bin/"darwincand", "--no-hardware"
    begin
      sleep 2
      assert_match "vcan0", shell_output("#{bin}/canctl link show")

      dump = IO.popen([bin/"candump", "-n", "1", "vcan0"])
      sleep 1
      system bin/"cansend", "vcan0", "123#DEADBEEF"
      assert_match "123   [4]  DE AD BE EF", dump.read
      dump.close

      (testpath/"test.c").write <<~C
        #include <stdio.h>
        #include <darwincan.h>

        int main(void)
        {
          dcan_raw *can = dcan_raw_open("vcan0");

          if (can == NULL) {
            fprintf(stderr, "%s\\n", dcan_last_error());
            return 1;
          }
          dcan_raw_close(can);
          return 0;
        }
      C
      system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-ldarwincan", "-o", "test"
      system "./test"
    ensure
      Process.kill("TERM", daemon)
      Process.wait(daemon)
    end
  end
end
