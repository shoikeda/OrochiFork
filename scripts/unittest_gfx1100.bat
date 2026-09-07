@echo off
REM Run Orochi unit tests for gfx1100 (Windows)
REM Usage: unittest_gfx1100.bat [Debug|DebugFast|RelWithDebInfo|Release] [extra UnitTest args...]

call "%~dp0_run_unittest.bat" gfx1100 generate_bitcodes_gfx1100.bat "-*getErrorString*" %*
exit /b %errorlevel%
