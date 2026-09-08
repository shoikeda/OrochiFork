#!/bin/sh
# Generate the bundled bitcodes the link_bundledBc* tests load.
# --gpu-bundle-output produces moduleTest*-hip-amdgcn-amd-amdhsa.bc, with no
# arch suffix; that name is what those tests open.

set -e

# Paths below are relative to this script, so the generation works anywhere.
cd "$(dirname "$0")"

# ROCm 10.0's officially supported targets, plus gfx1036 for the
# development machine's iGPU. Add gfx908 gfx90a gfx942 gfx950 when
# running on a datacenter part.
ARCHES="--offload-arch=gfx1030 \
        --offload-arch=gfx1036 \
        --offload-arch=gfx1100 \
        --offload-arch=gfx1101 \
        --offload-arch=gfx1102 \
        --offload-arch=gfx1103 \
        --offload-arch=gfx1150 \
        --offload-arch=gfx1151 \
        --offload-arch=gfx1152 \
        --offload-arch=gfx1153 \
        --offload-arch=gfx1200 \
        --offload-arch=gfx1201"

for src in moduleTestKernel moduleTestFunc; do
    hipcc --cuda-device-only $ARCHES -fgpu-rdc -c --gpu-bundle-output \
          -emit-llvm "../$src.cpp"
done
