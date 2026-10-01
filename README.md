# digidoc-fedora-build

Build the latest upstream [DigiDoc4 Client](https://github.com/open-eid/DigiDoc4-Client) (`qdigidoc4`) and [libdigidocpp](https://github.com/open-eid/libdigidocpp) from source on Fedora-based distros, without touching the system packages.

Distro repositories often lag behind upstream releases. This script builds the latest GitHub release and installs it into a user prefix. No root is needed except for installing build dependencies.

## Usage

```bash
git clone https://github.com/Gren-95/digidoc-fedora-build.git
cd digidoc-fedora-build
./build-digidoc.sh --deps   # first run: installs build dependencies with sudo dnf
./build-digidoc.sh          # later runs: rebuild at the latest upstream release
```

See [docs/DETAILS.md](docs/DETAILS.md) for build steps, configuration, requirements and PATH notes.

## License

MIT for this script. DigiDoc4 Client and libdigidocpp are licensed by their upstream authors (LGPL-2.1).
