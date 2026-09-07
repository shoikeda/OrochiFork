@echo off
REM Run Orochi unit tests for Navi 2 (Windows)
REM Usage: unittest_navi2.bat [Debug|DebugFast|RelWithDebInfo|Release] [extra UnitTest args...]

call "%~dp0_run_unittest.bat" navi2 none "-*getErrorString*:*link_bundledBc_with_bc_loweredName*" %*
exit /b %errorlevel%
