@echo off
REM Shared body for the unittest_*.bat runners.
REM Cleans the kernel cache, generates bitcodes, and runs the test suite.
REM Usage: call _run_unittest.bat <target> <bitcode-script|none> <gtest-filter> [config] [extra UnitTest args...]

REM Resolved before any shift, which renumbers %0 along with the arguments.
cd /d "%~dp0"

set "TARGET=%~1"
set "BITCODE=%~2"
set "FILTER=%~3"
shift
shift
shift

call _config.bat %1
if errorlevel 1 exit /b 1

REM %* ignores shift, so the forwarded arguments are rebuilt one at a time.
set "TEST_ARGS="
shift
:collect
if "%~1"=="" goto collected
set "TEST_ARGS=%TEST_ARGS% %1"
shift
goto collect
:collected

rd /s /q cache

if "%BITCODE%"=="none" goto run
if not exist "..\UnitTest\bitcodes\%BITCODE%" (
    echo error: bitcode generator not found: UnitTest\bitcodes\%BITCODE% 1>&2
    exit /b 1
)
pushd ..\UnitTest\bitcodes
call "%BITCODE%"
if errorlevel 1 (
    popd
    exit /b 1
)
popd

:run
"%UNITTEST_BIN%" %TEST_ARGS% --gtest_filter=%FILTER% --gtest_output=xml:../result_%TARGET%.xml
