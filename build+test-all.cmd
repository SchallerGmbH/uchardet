@echo off
rem ---------------------------------------------------------------------------
rem  build+test-all.cmd - build and test every target (Linux via WSL + Windows)
rem
rem  Usage: build+test-all.cmd [--rebuild]
rem    --rebuild  wipe each build directory first (clean configure)
rem
rem  Targets come from "build-target.cmd --list". A failing target does not stop
rem  the run; a summary is printed at the end. Exit code = number of failures.
rem  WSL distro: %UCHARDET_WSL_DISTRO% or the WSL default (see build-wsl.cmd).
rem ---------------------------------------------------------------------------
setlocal EnableExtensions EnableDelayedExpansion

set "REBUILD="
if /i "%~1"=="--rebuild" set "REBUILD=1"
if not "%~1"=="" if not defined REBUILD (
    echo Usage: %~nx0 [--rebuild]
    exit /b 1
)

set /a FAILED=0
set "SUMMARY="
for /f "usebackq tokens=1 delims=|" %%T in (`call "%~dp0build-target.cmd" --list`) do (
    set "RESULT=PASS"
    if defined REBUILD (
        call "%~dp0build-target.cmd" %%T clean >nul || set "RESULT=FAIL"
    )
    if "!RESULT!"=="PASS" (
        call "%~dp0build-target.cmd" %%T test || set "RESULT=FAIL"
    )
    if "!RESULT!"=="FAIL" set /a FAILED+=1
    set "SUMMARY=!SUMMARY! %%T:!RESULT!"
)

echo.
echo ===================== build+test-all summary =====================
for %%S in (%SUMMARY%) do (
    for /f "tokens=1,2 delims=:" %%a in ("%%S") do echo   %%b  %%a
)
echo ==================================================================
if %FAILED% equ 0 (echo   all targets passed) else (echo   %FAILED% target^(s^) FAILED)
exit /b %FAILED%
