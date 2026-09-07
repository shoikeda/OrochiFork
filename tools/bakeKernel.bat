@echo off
REM Bake GPU kernels into header files as string literals.
REM Generates: ParallelPrimitives/cache/Kernels.h and KernelArgs.h

REM Every path below is relative to the repository root, resolved from this
REM script's own location so the bake works from any working directory.
cd /d "%~dp0.."

set "CACHE=ParallelPrimitives\cache"
set "HEADER=// automatically generated, don't edit"

REM Built under .tmp and moved into place only on success, so an aborted run
REM cannot leave a truncated header that a later ORO_PP_LOAD_FROM_STRING build
REM would happily include.
echo %HEADER%> "%CACHE%\Kernels.h.tmp"
if errorlevel 1 goto fail
echo %HEADER%> "%CACHE%\KernelArgs.h.tmp"
if errorlevel 1 goto fail

python tools\stringify.py ./ParallelPrimitives/RadixSortKernels.h >> "%CACHE%\Kernels.h.tmp"
if errorlevel 1 goto fail
python tools\genArgs.py   ./ParallelPrimitives/RadixSortKernels.h >> "%CACHE%\KernelArgs.h.tmp"
if errorlevel 1 goto fail
python tools\stringify.py ./ParallelPrimitives/RadixSortConfigs.h >> "%CACHE%\Kernels.h.tmp"
if errorlevel 1 goto fail

move /y "%CACHE%\Kernels.h.tmp"    "%CACHE%\Kernels.h" >nul
if errorlevel 1 goto fail
move /y "%CACHE%\KernelArgs.h.tmp" "%CACHE%\KernelArgs.h" >nul
if errorlevel 1 goto fail
exit /b 0

:fail
del /q "%CACHE%\Kernels.h.tmp" "%CACHE%\KernelArgs.h.tmp" 2>nul
exit /b 1
