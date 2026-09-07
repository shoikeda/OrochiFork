@echo off
REM Run Orochi unit tests (Windows)
REM Cleans cache and runs the test suite excluding known-failing tests.
REM Usage: unittest.bat [Debug|DebugFast|RelWithDebInfo|Release] [extra UnitTest args...]

REM Every path below is relative to this script's directory.
cd /d "%~dp0"
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
"%UNITTEST_BIN%" %TEST_ARGS% --gtest_filter=-*link_bundledBc*:*VulkanComputeSimple64* --gtest_output=xml:../result.xml
