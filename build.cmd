@echo off
rem ---------------------------------------------------------------------------
rem  build.cmd - build uchardet on Windows with an MSYS2 MinGW toolchain
rem
rem  Usage: build.cmd [ENV] [CONFIG] [ACTION]
rem    ENV     mingw32 | mingw64 | ucrt64 | all      (default: ucrt64)
rem    CONFIG  Release | Debug                       (default: Release)
rem    ACTION  build | test | rebuild | clean        (default: build)
rem
rem  Output:   build\<ENV>-<config>\bin\  (uchardet.exe, libuchardet.dll, tests)
rem
rem  MSYS2 location: %MSYS2_ROOT%, else C:\dev\msys64, else C:\msys64.
rem  Required packages per ENV (pacman -S):
rem    mingw-w64-<arch>-gcc  mingw-w64-<arch>-cmake  mingw-w64-<arch>-ninja
rem    with <arch> = i686 (mingw32), x86_64 (mingw64), ucrt-x86_64 (ucrt64)
rem ---------------------------------------------------------------------------
setlocal EnableExtensions

set "SRC=%~dp0"
if "%SRC:~-1%"=="\" set "SRC=%SRC:~0,-1%"

set "ENV=%~1"
set "CONFIG=%~2"
set "ACTION=%~3"
if "%ENV%"==""    set "ENV=ucrt64"
if "%CONFIG%"=="" set "CONFIG=Release"
if "%ACTION%"=="" set "ACTION=build"

if /i "%ENV%"=="-h"     goto :usage
if /i "%ENV%"=="--help" goto :usage
if /i "%ENV%"=="/?"     goto :usage

if /i "%CONFIG%"=="release" set "CONFIG=Release"
if /i "%CONFIG%"=="debug"   set "CONFIG=Debug"
if not "%CONFIG%"=="Release" if not "%CONFIG%"=="Debug" (
    echo error: unknown CONFIG "%CONFIG%"
    goto :usage_fail
)
for %%A in (build test rebuild clean) do if /i "%ACTION%"=="%%A" goto :action_ok
echo error: unknown ACTION "%ACTION%"
goto :usage_fail
:action_ok

if not defined MSYS2_ROOT if exist "C:\dev\msys64\usr\bin\bash.exe" set "MSYS2_ROOT=C:\dev\msys64"
if not defined MSYS2_ROOT if exist "C:\msys64\usr\bin\bash.exe"     set "MSYS2_ROOT=C:\msys64"
if not defined MSYS2_ROOT (
    echo error: MSYS2 not found. Set MSYS2_ROOT to your MSYS2 installation.
    exit /b 1
)

if /i "%ENV%"=="all" (
    for %%E in (mingw32 mingw64 ucrt64) do (
        call :run %%E || exit /b 1
    )
    exit /b 0
)
for %%E in (mingw32 mingw64 ucrt64) do if /i "%ENV%"=="%%E" (
    call :run %%E
    exit /b
)
echo error: unknown ENV "%ENV%"
goto :usage_fail


rem ---------------------------------------------------------------------------
:run
setlocal
set "E=%~1"
set "BIN=%MSYS2_ROOT%\%E%\bin"
if /i "%CONFIG%"=="Debug" (set "CFG=debug") else (set "CFG=release")
set "BUILD=%SRC%\build\%E%-%CFG%"

if not exist "%BIN%\gcc.exe"   ( echo error: %BIN%\gcc.exe missing   & exit /b 1 )
if not exist "%BIN%\cmake.exe" ( echo error: %BIN%\cmake.exe missing & exit /b 1 )
if not exist "%BIN%\ninja.exe" ( echo error: %BIN%\ninja.exe missing & exit /b 1 )

rem Toolchain first, so no other cmake/gcc/ninja on PATH is picked up.
set "PATH=%BIN%;%MSYS2_ROOT%\usr\bin;%SystemRoot%\System32;%SystemRoot%"

echo.
echo === uchardet: %E% %CONFIG% %ACTION% -^> build\%E%-%CFG%

if /i "%ACTION%"=="clean"   goto :clean
if /i "%ACTION%"=="rebuild" if exist "%BUILD%" rmdir /s /q "%BUILD%"

cmake -S "%SRC%" -B "%BUILD%" -G Ninja ^
    -DCMAKE_BUILD_TYPE=%CONFIG% ^
    -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ ^
    -DCMAKE_INSTALL_PREFIX="%BUILD%/install" || exit /b 1
cmake --build "%BUILD%" || exit /b 1

if /i "%ACTION%"=="test" (
    ctest --test-dir "%BUILD%" --output-on-failure -j %NUMBER_OF_PROCESSORS% || exit /b 1
)
exit /b 0

:clean
if exist "%BUILD%" rmdir /s /q "%BUILD%"
echo removed %BUILD%
exit /b 0


rem ---------------------------------------------------------------------------
:usage
echo Usage: %~nx0 [mingw32^|mingw64^|ucrt64^|all] [Release^|Debug] [build^|test^|rebuild^|clean]
exit /b 0
:usage_fail
echo Usage: %~nx0 [mingw32^|mingw64^|ucrt64^|all] [Release^|Debug] [build^|test^|rebuild^|clean]
exit /b 1
