#!/bin/sh
# Bake GPU kernels into header files as string literals.
# Generates: ParallelPrimitives/cache/Kernels.h and KernelArgs.h

set -e

# Every path below is relative to the repository root, resolved from this
# script's own location so the bake works from any working directory.
cd "$(dirname "$0")/.."

CACHE=ParallelPrimitives/cache
HEADER="// automatically generated, don't edit"

# Built under .tmp and moved into place only on success, so an aborted run
# cannot leave a truncated header that a later ORO_PP_LOAD_FROM_STRING build
# would happily include.
trap 'rm -f "$CACHE/Kernels.h.tmp" "$CACHE/KernelArgs.h.tmp"' EXIT

echo "$HEADER" > "$CACHE/Kernels.h.tmp"
echo "$HEADER" > "$CACHE/KernelArgs.h.tmp"

python3 tools/stringify.py ./ParallelPrimitives/RadixSortKernels.h >> "$CACHE/Kernels.h.tmp"
python3 tools/genArgs.py   ./ParallelPrimitives/RadixSortKernels.h >> "$CACHE/KernelArgs.h.tmp"
python3 tools/stringify.py ./ParallelPrimitives/RadixSortConfigs.h >> "$CACHE/Kernels.h.tmp"

mv "$CACHE/Kernels.h.tmp"    "$CACHE/Kernels.h"
mv "$CACHE/KernelArgs.h.tmp" "$CACHE/KernelArgs.h"
