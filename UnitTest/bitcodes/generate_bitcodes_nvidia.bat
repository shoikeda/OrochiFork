@echo off
REM Generate the CUDA fatbins the link_bundledBc* tests load.
REM The sources are .cpp, so -x cu is needed to compile them as CUDA.

REM Paths below are relative to this script, so the generation works anywhere.
cd /d "%~dp0"

REM all-major emits SASS for the major versions only: much smaller and quicker to
REM build than -arch=all, at the cost of JIT on a minor-version mismatch.
for %%S in (moduleTestFunc moduleTestKernel) do (
    call nvcc -x cu -fatbin --device-c -arch=all-major "../%%S.cpp"
    if errorlevel 1 exit /b 1
)
