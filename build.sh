#!/usr/bin/env bash
# ---------------------------------------------------------------------------
#  build.sh - build uchardet on Linux (also works in WSL and MSYS2 shells)
#
#  Usage: ./build.sh [CONFIG] [ACTION]
#    CONFIG  Release | Debug                 (default: Release)
#    ACTION  build | test | rebuild | clean  (default: build)
#
#  Output: build/<platform>-<config>/bin/  e.g. build/linux-release/bin/uchardet
#
#  Needs: cmake, a C/C++ compiler; ninja is used if installed, else make.
#  Debian/Ubuntu: sudo apt install build-essential cmake [ninja-build]
#  Override compiler with CC=clang CXX=clang++ ./build.sh
# ---------------------------------------------------------------------------
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${1:-Release}"
ACTION="${2:-build}"

usage() { echo "Usage: $0 [Release|Debug] [build|test|rebuild|clean]"; }

case "${CONFIG,,}" in
    release) CONFIG=Release ;;
    debug)   CONFIG=Debug ;;
    -h|--help) usage; exit 0 ;;
    *) echo "error: unknown CONFIG '$CONFIG'"; usage; exit 1 ;;
esac
case "$ACTION" in
    build|test|rebuild|clean) ;;
    *) echo "error: unknown ACTION '$ACTION'"; usage; exit 1 ;;
esac

# Platform tag for the build directory (MSYS2 shells report their MSYSTEM).
if [ -n "${MSYSTEM:-}" ] && [ "$MSYSTEM" != "MSYS" ]; then
    PLATFORM="${MSYSTEM,,}"
else
    PLATFORM="$(uname -s | tr '[:upper:]' '[:lower:]')"
fi
BUILD="$SRC/build/$PLATFORM-${CONFIG,,}"

for tool in cmake; do
    command -v "$tool" >/dev/null || { echo "error: '$tool' not found"; exit 1; }
done
if command -v ninja >/dev/null; then GEN=Ninja; else GEN="Unix Makefiles"; fi
JOBS="$(nproc 2>/dev/null || echo 4)"

echo "=== uchardet: $PLATFORM $CONFIG $ACTION -> ${BUILD#"$SRC"/} ($GEN)"

if [ "$ACTION" = clean ]; then
    rm -rf "$BUILD"; echo "removed $BUILD"; exit 0
fi
[ "$ACTION" = rebuild ] && rm -rf "$BUILD"

cmake -S "$SRC" -B "$BUILD" -G "$GEN" \
    -DCMAKE_BUILD_TYPE="$CONFIG" \
    -DCMAKE_INSTALL_PREFIX="$BUILD/install"
cmake --build "$BUILD" --parallel "$JOBS"

if [ "$ACTION" = test ]; then
    ctest --test-dir "$BUILD" --output-on-failure -j "$JOBS"
fi
