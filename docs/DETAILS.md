# Details

## What the script does

1. Looks up the latest release tags of `open-eid/libdigidocpp` and `open-eid/DigiDoc4-Client`.
2. Clones both (with submodules) into `~/.cache/digidoc-build`.
3. Builds libdigidocpp, then qdigidoc4, with CMake and Ninja in Release mode.
4. Installs into `~/.local/opt/digidoc` with an RPATH, so the bundled library is used.
5. Symlinks `~/.local/bin/qdigidoc4` and installs the desktop entry, icons and MIME types under `~/.local/share`.

The Nautilus and KDE file-manager extensions are not built.

## Configuration

| Variable | Default | Purpose |
|----------|---------|---------|
| `DIGIDOC_PREFIX` | `~/.local/opt/digidoc` | Install prefix |
| `DIGIDOC_WORK` | `~/.cache/digidoc-build` | Clone and build directory |

## Requirements

- Fedora or a derivative (tested on Nobara 44), `dnf`, and `sudo` for `--deps`
- Network access to GitHub and the EU/Estonian TSL servers (the build downloads trust lists)

## PATH and packaged installs

Make sure `~/.local/bin` comes before `/usr/bin` in `PATH` if a packaged `qdigidoc4` is also installed. To remove the packaged version:

```bash
sudo dnf remove qdigidoc libdigidocpp
```
