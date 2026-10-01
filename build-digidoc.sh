#!/usr/bin/env bash
# Build DigiDoc4 client (qdigidoc4) and libdigidocpp from source at latest upstream release.
# Installs into a user prefix (no root except for build deps); the system RPM is left untouched.
#
# Usage: build-digidoc.sh [--deps]   (--deps installs build dependencies via sudo dnf)
set -euo pipefail

PREFIX="${DIGIDOC_PREFIX:-$HOME/.local/opt/digidoc}"
WORK="${DIGIDOC_WORK:-$HOME/.cache/digidoc-build}"
BIN_DIR="$HOME/.local/bin"
SHARE_DIR="$HOME/.local/share"
APP_DIR="$SHARE_DIR/applications"
JOBS="$(nproc)"

BUILD_DEPS=(
    git cmake ninja-build gcc-c++ pkgconf-pkg-config
    openssl-devel libxml2-devel zlib-devel xmlsec1-devel xmlsec1-openssl-devel
    minizip-ng-compat-devel libtool-ltdl-devel
    qt6-qtbase-devel qt6-qtsvg-devel qt6-qttools-devel
    openldap-devel pcsc-lite-devel flatbuffers-devel flatbuffers-compiler
    opensc
)

latest_tag() {
    curl -fsSL "https://api.github.com/repos/open-eid/$1/releases/latest" \
        | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -n1
}

fetch_source() {
    local repo="$1" tag="$2" dir="$WORK/$1"
    rm -rf "$dir"
    git clone --quiet --depth 1 --branch "$tag" --recurse-submodules --shallow-submodules \
        "https://github.com/open-eid/$repo.git" "$dir"
}

cmake_install() {
    local src="$1"; shift
    cmake -S "$src" -B "$src/build" -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$PREFIX" \
        -DCMAKE_INSTALL_LIBDIR=lib \
        -DCMAKE_INSTALL_RPATH="$PREFIX/lib" \
        -DCMAKE_PREFIX_PATH="$PREFIX" \
        "$@"
    cmake --build "$src/build" --parallel "$JOBS"
    cmake --install "$src/build"
}

if [[ "${1:-}" == "--deps" ]]; then
    sudo dnf install -y "${BUILD_DEPS[@]}"
fi

mkdir -p "$WORK"
lib_tag="$(latest_tag libdigidocpp)"
app_tag="$(latest_tag DigiDoc4-Client)"
[[ -n "$lib_tag" && -n "$app_tag" ]] || { echo "Could not resolve latest upstream tags" >&2; exit 1; }
echo "Building libdigidocpp $lib_tag and DigiDoc4-Client $app_tag into $PREFIX"

fetch_source libdigidocpp "$lib_tag"
cmake_install "$WORK/libdigidocpp" -DCMAKE_DISABLE_FIND_PACKAGE_SWIG=ON -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=ON

fetch_source DigiDoc4-Client "$app_tag"
cmake_install "$WORK/DigiDoc4-Client" -DENABLE_KDE=OFF -DENABLE_NAUTILUS_EXTENSION=OFF

mkdir -p "$BIN_DIR" "$APP_DIR" "$SHARE_DIR/icons" "$SHARE_DIR/mime/packages"
ln -sf "$PREFIX/bin/qdigidoc4" "$BIN_DIR/qdigidoc4"
sed "s|^Exec=qdigidoc4|Exec=$PREFIX/bin/qdigidoc4|" \
    "$PREFIX/share/applications/ee.ria.qdigidoc4.desktop" > "$APP_DIR/ee.ria.qdigidoc4.desktop"
cp -r "$PREFIX/share/icons/." "$SHARE_DIR/icons/"
cp "$PREFIX/share/mime/packages/qdigidoc4.xml" "$SHARE_DIR/mime/packages/"
update-mime-database "$SHARE_DIR/mime"
update-desktop-database "$APP_DIR"
gtk-update-icon-cache -q -f "$SHARE_DIR/icons/hicolor" 2>/dev/null || true

echo "Done. Installed:"
"$PREFIX/bin/qdigidoc4" --version 2>/dev/null || ls -l "$PREFIX/bin/qdigidoc4"
