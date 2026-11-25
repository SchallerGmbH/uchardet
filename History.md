# Software History

Change history of the software uchardet, Newest entries first.

Each entry is listed as **date · branch** and grouped by type:

| Type | Meaning |
|------|---------|
| `new` | new feature or function |
| `fix` | bug fix |
| `improved` | improved existing behaviour |
| `change` | changed behaviour, renaming, moves |
| `cleanup` | refactoring / code cleanup without functional change |
| `removed` | removed feature or code |
| `build` | makefiles, build scripts, bootloaders |
| `toolchain` | compiler, avrdude, VS Code tasks and settings |
| `experimental` | preliminary, not finished or untested |


**Years:** [2026](#2026) · 

---

## Unreleased

### 25.11.2026 · `cchardet`

- **build** · New `gh-release.sh [TAG]` / `gh-release.cmd [TAG]` (default `v0.8.0`, same behaviour): copies the
  Release binaries of all 4 platforms to `dist/` (`uchardet-<TAG>-win32-mingw32.exe`, `-win64-mingw64.exe`,
  `-win64-ucrt64.exe`, `-linux-x86_64`) and creates the GitHub release with `gh release create`
  (notes: `claude/00/release-<TAG>.md`). Stops before `gh` runs if `gh`, the release notes or a build output is
  missing. Runs from any folder.
- **build** · `.gitignore`: `/dist/`.

## v0.8.0

### 25.11.2026 · `vscode/win+wsl`

- **fix** · Windows binaries printed nothing (`-v`, `-h`, …) outside an MSYS2 shell: `libstdc++-6.dll`,
  `libgcc_s_*.dll` and `libwinpthread-1.dll` were missing (STATUS_DLL_NOT_FOUND). The GCC runtime is now linked
  statically on MinGW (`-static`, CMake option `MINGW_STATIC_RUNTIME`, default ON).
- **fix** · Debug builds failed to link on MinGW (mingw32/mingw64/ucrt64): `-fsanitize=address` is now only added
  when `NOT MINGW`, because MinGW-w64 GCC has no libasan.
- **fix** · Windows: tests and `uchardet.exe` could not find `libuchardet.dll`. All executables (and the DLL) are
  now written to `<build>/bin`.
- **change** · The executables (`uchardet`, `uchardet-tests`, `uchardet-lifecycle-tests`) now link the static
  `libuchardet` on all platforms (CMake option `STATIC_EXECUTABLES`, default ON), so they no longer need
  `libuchardet.dll` / `libuchardet.so.0`. The shared library is still built and installed. The tests use the C++
  linker when they link the static lib.
- **change** · Executables are now written to `<build>/bin` on every platform (Linux: `build/linux-<cfg>/bin`).
- **build** · New `build.cmd`: Windows build with MSYS2 `mingw32` (i686), `mingw64`, `ucrt64`, Ninja,
  `build.cmd [mingw32|mingw64|ucrt64|all] [Release|Debug] [build|test|rebuild|clean]` → `build/<env>-<cfg>`.
  MSYS2 location comes from `%MSYS2_ROOT%`, then `C:\dev\msys64`, then `C:\msys64`.
- **build** · New `build.sh`: Linux build (also WSL / MSYS2 shells), `./build.sh [Release|Debug] [ACTION]`.
  Uses Ninja if installed, otherwise make.
- **build** · New `build-wsl.cmd`: runs `build.sh` in WSL. The distro comes from `%UCHARDET_WSL_DISTRO%`, otherwise
  the WSL default.
- **build** · New `build-target.cmd`: builds one target by name (`linux|mingw32|mingw64|ucrt64` + `-debug|-release`),
  `--list` lists all targets.
- **build** · New `build+test-all.cmd`: builds and tests all 8 targets (Linux + Windows), prints a PASS/FAIL summary,
  exit code = number of failures, `--rebuild` for a clean run.
- **build** · `.gitattributes`: `*.sh` LF, `*.cmd`/`*.bat` CRLF. `.gitignore`: `/build/` and `/claude/`.
- **toolchain** · New `.vscode/tasks.json`: "Build target ..." with a target picker
  (`augustocdias.tasks-shell-input`, list from `build-target.cmd --list`), "Build+test all targets"
  (optionally clean rebuild), "Windows: build ..." and "Linux (WSL): build ...". The default build
  (Ctrl+Shift+B) is ucrt64 Release.
- **toolchain** · Tested: all 8 targets (linux, mingw32, mingw64, ucrt64 × Debug/Release) build and pass
  154/154 tests. The mingw32 build is a 32-bit i386 PE32 binary.