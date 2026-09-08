#!/bin/sh
# Generate the CUDA fatbins the link_bundledBc* tests load.
# The sources are .cpp, so -x cu is needed to compile them as CUDA.

set -e

# Paths below are relative to this script, so the generation works anywhere.
cd "$(dirname "$0")"

# all-major emits SASS for the major versions only: much smaller and quicker to
# build than -arch=all, at the cost of JIT on a minor-version mismatch.
for src in moduleTestFunc moduleTestKernel; do
    nvcc -x cu -fatbin --device-c -arch=all-major "../$src.cpp"
done
