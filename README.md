# Homebrew tap for darwinCAN

[darwinCAN](https://github.com/b3rtoz/darwincan) is SocketCAN-style CAN bus access for macOS: a daemon that owns USB CAN adapters and shares them between programs, with the can-utils tools and libraries for Rust, C and Python.

```sh
brew install b3rtoz/darwincan/darwincan
darwincand install       # registers the daemon as a launch agent for your user
```

The formula builds darwinCAN from source; Homebrew installs Rust for the build. Report problems with darwinCAN itself or with this formula at [b3rtoz/darwincan](https://github.com/b3rtoz/darwincan/issues).
