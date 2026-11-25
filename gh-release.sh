#!/usr/bin/env bash
# ---------------------------------------------------------------------------
#  gh-release.sh - copy the release binaries to dist/ and create the
#                  GitHub release (bash variant of gh-release.cmd)
#
#  Usage: ./gh-release.sh [TAG]       (default: v0.8.0)
#  Needs: gh (GitHub CLI, logged in), Release builds of all targets
#         (e.g. build+test-all.cmd --rebuild)
# ---------------------------------------------------------------------------
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

TAG="${1:-v0.8.0}"
NOTES="claude/00/release-$TAG.md"

command -v gh >/dev/null || { echo "error: gh (GitHub CLI) not found"; exit 1; }
[ -f "$NOTES" ] || { echo "error: release notes \"$NOTES\" not found"; exit 1; }

copy() {
    [ -f "$1" ] || { echo "error: \"$1\" missing - build it first"; exit 1; }
    cp -f "$1" "$2" || { echo "error: copy \"$1\" failed"; exit 1; }
    echo "  $1 -> $2"
}

mkdir -p dist
copy build/mingw32-release/bin/uchardet.exe "dist/uchardet-$TAG-win32-mingw32.exe"
copy build/mingw64-release/bin/uchardet.exe "dist/uchardet-$TAG-win64-mingw64.exe"
copy build/ucrt64-release/bin/uchardet.exe  "dist/uchardet-$TAG-win64-ucrt64.exe"
copy build/linux-release/bin/uchardet       "dist/uchardet-$TAG-linux-x86_64"

gh release create "$TAG" --title "uchardet $TAG" \
  --notes-file "$NOTES" \
  "dist/uchardet-$TAG-win32-mingw32.exe" \
  "dist/uchardet-$TAG-win64-mingw64.exe" \
  "dist/uchardet-$TAG-win64-ucrt64.exe" \
  "dist/uchardet-$TAG-linux-x86_64"
