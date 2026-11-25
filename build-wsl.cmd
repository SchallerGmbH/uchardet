@echo off
rem ---------------------------------------------------------------------------
rem  build-wsl.cmd - run the Linux build (build.sh) inside WSL
rem
rem  Usage: build-wsl.cmd [CONFIG] [ACTION]
rem    CONFIG  Release | Debug                 (default: Release)
rem    ACTION  build | test | rebuild | clean  (default: build)
rem
rem  Distro: %UCHARDET_WSL_DISTRO% if set, otherwise the WSL default distro.
rem    e.g.  set UCHARDET_WSL_DISTRO=Debian-13
rem
rem  Output: build\linux-<config>\bin\  (built inside WSL on /mnt/<drive>/...)
rem  The distro needs: cmake, gcc/g++ (and optionally ninja).
rem ---------------------------------------------------------------------------
setlocal EnableExtensions

set "SRC=%~dp0"
if "%SRC:~-1%"=="\" set "SRC=%SRC:~0,-1%"

where wsl.exe >nul 2>&1 || (
    echo error: wsl.exe not found - is WSL installed?
    exit /b 1
)

if defined UCHARDET_WSL_DISTRO (
    echo === WSL distro: %UCHARDET_WSL_DISTRO%
    wsl.exe -d "%UCHARDET_WSL_DISTRO%" --cd "%SRC%" -- ./build.sh %*
) else (
    echo === WSL distro: ^<default^>
    wsl.exe --cd "%SRC%" -- ./build.sh %*
)
exit /b %ERRORLEVEL%
