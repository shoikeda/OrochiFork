@echo off
REM Run Orochi unit tests (Windows)
REM Usage: unittest.bat [Debug|DebugFast|RelWithDebInfo|Release] [extra UnitTest args...]

call "%~dp0_run_unittest.bat" default none "-*link_bundledBc*:*VulkanComputeSimple64*" %*
exit /b %errorlevel%
