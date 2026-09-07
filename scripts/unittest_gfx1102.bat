@echo off
REM Run Orochi unit tests for gfx1102 (Windows)
REM Usage: unittest_gfx1102.bat [Debug|DebugFast|RelWithDebInfo|Release] [extra UnitTest args...]

call "%~dp0_run_unittest.bat" gfx1102 generate_bitcodes_gfx1102.bat "-*getErrorString*" %*
exit /b %errorlevel%
