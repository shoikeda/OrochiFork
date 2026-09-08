@echo off
REM Generate the bundled bitcodes the link_bundledBc* tests load.
REM --gpu-bundle-output produces moduleTest*-hip-amdgcn-amd-amdhsa.bc, with no
REM arch suffix; that name is what those tests open.

REM Paths below are relative to this script, so the generation works anywhere.
cd /d "%~dp0"

REM ROCm 10.0's officially supported targets, plus gfx1036 for the
REM development machine's iGPU. Add gfx908 gfx90a gfx942 gfx950 when
REM running on a datacenter part.
set "ARCHES=--offload-arch=gfx1030 ^
    --offload-arch=gfx1036 ^
    --offload-arch=gfx1100 ^
    --offload-arch=gfx1101 ^
    --offload-arch=gfx1102 ^
    --offload-arch=gfx1103 ^
    --offload-arch=gfx1150 ^
    --offload-arch=gfx1151 ^
    --offload-arch=gfx1152 ^
    --offload-arch=gfx1153 ^
    --offload-arch=gfx1200 ^
    --offload-arch=gfx1201"

for %%S in (moduleTestKernel moduleTestFunc) do (
    call hipcc --cuda-device-only %ARCHES% -fgpu-rdc -c --gpu-bundle-output -emit-llvm "../%%S.cpp"
    if errorlevel 1 exit /b 1
)
