@echo off
rem ---------------------------------------------------------------------------
rem  gh-release.cmd - copy the release binaries to dist\ and create the
rem                   GitHub release (cmd variant of gh-release.sh)
rem
rem  Usage: gh-release.cmd [TAG]       (default: v0.8.0)
rem  Needs: gh (GitHub CLI, logged in), Release builds of all targets
rem         (e.g. build+test-all.cmd --rebuild)
rem ---------------------------------------------------------------------------
setlocal EnableExtensions
cd /d "%~dp0"

set "TAG=%~1"
if "%TAG%"=="" set "TAG=v0.8.0"
set "NOTES=claude\00\release-%TAG%.md"

where gh >nul 2>&1 || ( echo error: gh ^(GitHub CLI^) not found & exit /b 1 )
if not exist "%NOTES%" ( echo error: release notes "%NOTES%" not found & exit /b 1 )

if not exist dist mkdir dist
call :copy build\mingw32-release\bin\uchardet.exe dist\uchardet-%TAG%-win32-mingw32.exe || exit /b 1
call :copy build\mingw64-release\bin\uchardet.exe dist\uchardet-%TAG%-win64-mingw64.exe || exit /b 1
call :copy build\ucrt64-release\bin\uchardet.exe  dist\uchardet-%TAG%-win64-ucrt64.exe  || exit /b 1
call :copy build\linux-release\bin\uchardet       dist\uchardet-%TAG%-linux-x86_64      || exit /b 1

gh release create %TAG% --title "uchardet %TAG%" ^
  --notes-file "%NOTES%" ^
  dist\uchardet-%TAG%-win32-mingw32.exe ^
  dist\uchardet-%TAG%-win64-mingw64.exe ^
  dist\uchardet-%TAG%-win64-ucrt64.exe ^
  dist\uchardet-%TAG%-linux-x86_64
exit /b %ERRORLEVEL%


:copy
if not exist "%~1" ( echo error: "%~1" missing - build it first & exit /b 1 )
copy /y "%~1" "%~2" >nul || ( echo error: copy "%~1" failed & exit /b 1 )
echo   %~1 -^> %~2
exit /b 0
