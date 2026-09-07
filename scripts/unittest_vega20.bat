@echo off
REM Run Orochi unit tests for Vega 20 (Windows)
REM Usage: unittest_vega20.bat [Debug|DebugFast|RelWithDebInfo|Release] [extra UnitTest args...]

call "%~dp0_run_unittest.bat" vega20 none "-*getErrorString*:*link_bundledBc_with_bc_loweredName*" %*
exit /b %errorlevel%
