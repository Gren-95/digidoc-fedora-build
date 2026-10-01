# digidoc-build

Build the latest upstream [DigiDoc4 Client](https://github.com/open-eid/DigiDoc4-Client) (`qdigidoc4`) and [libdigidocpp](https://github.com/open-eid/libdigidocpp) from source on Fedora-based distros, without touching the system packages.

Distro repositories often lag behind upstream releases. This script resolves the latest GitHub release tags, builds both projects, and installs them into a user prefix. No root is needed except for installing build dependencies.

## Usage

```bash
git clone https://github.com/Gren-95/digidoc-build.git
cd digidoc-build
./build-digidoc.sh --deps   # first run: installs build dependencies with sudo dnf
./build-digidoc.sh          # later runs: rebuild at the latest upstream release
```

Make sure `~/.local/bin` comes before `/usr/bin` in `PATH` if a packaged `qdigidoc4` is also installed.

## What it does

1. Looks up the latest release tags of `open-eid/libdigidocpp` and `open-eid/DigiDoc4-Client`.
2. Clones both (with submodules) into `~/.cache/digidoc-build`.
3. Builds libdigidocpp, then qdigidoc4, with CMake and Ninja in Release mode.
4. Installs into `~/.local/opt/digidoc` with an RPATH, so the bundled library is used.
5. Symlinks `~/.local/bin/qdigidoc4` and installs the desktop entry, icons and MIME types under `~/.local/share`.

## Configuration

| Variable | Default | Purpose |
|----------|---------|---------|
| `DIGIDOC_PREFIX` | `~/.local/opt/digidoc` | Install prefix |
| `DIGIDOC_WORK` | `~/.cache/digidoc-build` | Clone and build directory |

## Requirements

- Fedora or a derivative (tested on Nobara 44), `dnf`, `sudo` for `--deps`
- Network access to GitHub and the EU/Estonian TSL servers (the build downloads trust lists)

The Nautilus and KDE file-manager extensions are not built.

## License

MIT for this script. DigiDoc4 Client and libdigidocpp are licensed by their upstream authors (LGPL-2.1).
