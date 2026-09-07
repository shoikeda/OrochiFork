@echo off
REM Run Orochi unit tests for Vega 10 (Windows)
REM Usage: unittest_vega10.bat [Debug|DebugFast|RelWithDebInfo|Release] [extra UnitTest args...]

call "%~dp0_run_unittest.bat" vega10 none "-*getErrorString*:*link_bundledBc_with_bc_loweredName*" %*
exit /b %errorlevel%
