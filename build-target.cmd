@echo off
rem ---------------------------------------------------------------------------
rem  build-target.cmd - build one target by name
rem
rem  Usage: build-target.cmd TARGET [ACTION]
rem         build-target.cmd --list
rem    TARGET  <platform>-<config>, e.g. linux-release, mingw32-debug, ucrt64-release
rem            platform: linux (via build-wsl.cmd) | mingw32 | mingw64 | ucrt64 (via build.cmd)
rem            config:   debug | release
rem    ACTION  build | test | rebuild | clean  (default: build)
rem
rem  --list prints all targets as  value|label|description  (one per line),
rem  used by the VS Code input "BuildTargetsIn" (augustocdias.tasks-shell-input).
rem ---------------------------------------------------------------------------
setlocal EnableExtensions

if "%~1"==""          goto :usage_fail
if /i "%~1"=="--list" goto :list
if /i "%~1"=="-h"     goto :usage
if /i "%~1"=="--help" goto :usage

set "TARGET=%~1"
set "ACTION=%~2"
if "%ACTION%"=="" set "ACTION=build"

set "PLAT="
set "CFG="
for /f "tokens=1,2 delims=-" %%a in ("%TARGET%") do (
    set "PLAT=%%a"
    set "CFG=%%b"
)
if /i not "%CFG%"=="debug" if /i not "%CFG%"=="release" (
    echo error: unknown target "%TARGET%"
    goto :usage_fail
)

if /i "%PLAT%"=="linux" (
    call "%~dp0build-wsl.cmd" %CFG% %ACTION%
    exit /b
)
for %%P in (mingw32 mingw64 ucrt64) do if /i "%PLAT%"=="%%P" (
    call "%~dp0build.cmd" %PLAT% %CFG% %ACTION%
    exit /b
)
echo error: unknown target "%TARGET%"
goto :usage_fail


:list
if defined UCHARDET_WSL_DISTRO (set "WSLD=%UCHARDET_WSL_DISTRO%") else (set "WSLD=default distro")
echo linux-debug^|linux-debug^|Linux x86-64, WSL %WSLD%
echo linux-release^|linux-release^|Linux x86-64, WSL %WSLD%
echo mingw32-debug^|mingw32-debug^|Windows 32-bit i686, msvcrt
echo mingw32-release^|mingw32-release^|Windows 32-bit i686, msvcrt
echo mingw64-debug^|mingw64-debug^|Windows 64-bit x86-64, msvcrt
echo mingw64-release^|mingw64-release^|Windows 64-bit x86-64, msvcrt
echo ucrt64-debug^|ucrt64-debug^|Windows 64-bit x86-64, UCRT
echo ucrt64-release^|ucrt64-release^|Windows 64-bit x86-64, UCRT
exit /b 0

:usage
echo Usage: %~nx0 ^<linux^|mingw32^|mingw64^|ucrt64^>-^<debug^|release^> [build^|test^|rebuild^|clean]
echo        %~nx0 --list
exit /b 0
:usage_fail
echo Usage: %~nx0 ^<linux^|mingw32^|mingw64^|ucrt64^>-^<debug^|release^> [build^|test^|rebuild^|clean]
echo        %~nx0 --list
exit /b 1
