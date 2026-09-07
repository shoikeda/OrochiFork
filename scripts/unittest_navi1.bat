@echo off
REM Run Orochi unit tests for Navi 1 (Windows)
REM Usage: unittest_navi1.bat [Debug|DebugFast|RelWithDebInfo|Release] [extra UnitTest args...]

call "%~dp0_run_unittest.bat" navi1 none "-*getErrorString*:*link_bundledBc_with_bc_loweredName*" %*
exit /b %errorlevel%
