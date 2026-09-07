"""Compile GPU kernels for both AMD (hipcc) and NVIDIA (nvcc) targets.

Compiles ParallelPrimitives radix sort kernels into fatbin/hipfb files
for use with precompiled kernel loading.
"""
import json
import subprocess
import sys
from pathlib import Path
from typing import Final

from enumArch import enumArch

# Resolved from this file rather than the working directory, so the script can
# be run from anywhere.
_SCRIPTS: Final = Path(__file__).resolve().parent
_ROOT: Final = _SCRIPTS.parent

_KERNELS: Final = _ROOT / "ParallelPrimitives" / "RadixSortKernels.h"
_OUTPUT_DIR: Final = _ROOT / "bitcodes"

_MIN_ARCH: Final = "gfx900"


def get_gpu_list() -> dict[str, list[str]]:
    """Load the AMD GPU list from the JSON configuration file."""
    return json.loads((_SCRIPTS / "amdGpuList.json").read_text(encoding="utf-8"))


def get_amd_arches(min_arch: str) -> list[str]:
    """Return the AMD arches to build, falling back to the JSON list."""
    arches = enumArch(min_arch)
    if not arches:
        print(
            "architecture enumeration unavailable; falling back to amdGpuList.json",
            file=sys.stderr,
        )
        arches = get_gpu_list()["amd"]
    return arches


def build_command(target: str) -> list[str]:
    """Build the compiler command line for 'hipcc' or 'nvcc'."""
    if target == "hipcc":
        command = [
            "hipcc",
            "-x", "hip",
            str(_KERNELS),
            "-O3", "-std=c++17", "-ffast-math",
            "--cuda-device-only", "--genco",
            f"-I{_ROOT}", "-include", "hip/hip_runtime.h",
            "-parallel-jobs=15",
        ]
        command += [f"--offload-arch={arch}" for arch in get_amd_arches(_MIN_ARCH)]
        command += ["-o", str(_OUTPUT_DIR / "oro_compiled_kernels.hipfb")]
        return command

    return [
        "nvcc",
        "-x", "cu",
        str(_KERNELS),
        "-O3", "-std=c++17", "--use_fast_math",
        "-fatbin", "-arch=all",
        f"-I{_ROOT}", "-include", "cuda_runtime.h",
        "-o", str(_OUTPUT_DIR / "oro_compiled_kernels.fatbin"),
    ]


def main() -> int:
    _OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    running: list[tuple[str, subprocess.Popen[bytes]]] = []
    failed: list[str] = []

    for target in ("hipcc", "nvcc"):
        command = build_command(target)
        print(" ".join(command))
        try:
            running.append((target, subprocess.Popen(command)))
        except OSError as exc:
            # Recorded rather than raised, so a compiler that is present still
            # finishes instead of being orphaned by the traceback.
            failed.append(f"{target} ({exc.strerror or exc})")

    try:
        for target, proc in running:
            if proc.wait() != 0:
                failed.append(f"{target} (exit {proc.returncode})")
    finally:
        for _, proc in running:
            if proc.poll() is None:
                proc.kill()
                proc.wait()

    if failed:
        print("compile failed: " + ", ".join(failed), file=sys.stderr)
        return 1

    print("compile done.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
