"""Enumerate AMD GPU architectures supported by the installed LLVM toolchain.

Provides enumArch(minArch) which returns a list of supported gfx targets
at or above the given minimum architecture.

Queries ROCm's clang first and falls back to llc: recent ROCm packages no
longer ship llc, but clang's -mcpu=help listing is equivalent for this purpose.
"""
import functools
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path
from typing import Final

# Matches the leading "gfxNNN" column of both clang's and llc's -mcpu=help
# listing, rejecting the "gfx10-3-generic" style pseudo targets.
_ARCH_PATTERN: Final = re.compile(r"^\s+(gfx[0-9a-f]+)(?=\s|$)")

# Candidate command lines, in priority order. Each yields a -mcpu=help listing.
_ENUM_COMMANDS: Final = (
    ("clang", ["--target=amdgcn-amd-amdhsa", "-mcpu=help"]),
    ("llc", ["-march=amdgcn", "-mcpu=help"]),
)

# A real target has at least three digits, so "gfx9" rows are rejected.
_MIN_ARCH_LEN: Final = 6

# Bounded so a wedged toolchain query cannot hang the build indefinitely.
_TIMEOUT_SEC: Final = 30


def to_number(arch: str) -> int:
    """Convert a gfx architecture string (e.g. 'gfx900') to an integer."""
    return int(arch[3:], 16)


def _run(command: list[str]) -> subprocess.CompletedProcess[str] | None:
    """Run a toolchain query, returning None if it cannot be run or times out."""
    try:
        return subprocess.run(
            command,
            capture_output=True,
            text=True,
            check=False,
            timeout=_TIMEOUT_SEC,
        )
    except (OSError, subprocess.SubprocessError) as exc:
        print(f"warning: could not run {command[0]}: {exc}", file=sys.stderr)
        return None


@functools.cache
def _rocm_llvm_bin() -> str | None:
    """Return ROCm's LLVM bin directory, or None if ROCm is not installed."""
    for var in ("ROCM_PATH", "HIP_PATH"):
        root = os.environ.get(var)
        if root:
            candidate = Path(root) / "lib" / "llvm" / "bin"
            if candidate.is_dir():
                return str(candidate)

    hipconfig = shutil.which("hipconfig")
    if hipconfig:
        result = _run([hipconfig, "-l"])
        if result and result.returncode == 0 and result.stdout.strip():
            return result.stdout.strip()

    roots = [Path("/opt/rocm")]
    # Windows installs land under a versioned directory, newest first.
    program_files = Path(os.environ.get("ProgramFiles", "C:/Program Files")) / "AMD" / "ROCm"
    if program_files.is_dir():
        roots += sorted(program_files.iterdir(), reverse=True)
    roots.append(program_files)

    for root in roots:
        candidate = root / "lib" / "llvm" / "bin"
        if candidate.is_dir():
            return str(candidate)

    return None


@functools.cache
def _device_library_arches() -> frozenset[str] | None:
    """Targets ROCm ships a device library for, or None if none can be located.

    clang lists every target it can generate code for, which is a superset of
    what hipcc can link: building for the difference fails with "cannot find
    ROCm device library".
    """
    rocm_bin = _rocm_llvm_bin()
    if not rocm_bin:
        return None

    bitcode = Path(rocm_bin).parent / "amdgcn" / "bitcode"
    if not bitcode.is_dir():
        return None

    prefix, suffix = "oclc_isa_version_", ".bc"
    arches = frozenset(
        f"gfx{path.name[len(prefix):-len(suffix)]}"
        for path in bitcode.glob(f"{prefix}*{suffix}")
    )

    return arches or None


def _find_tool(name: str) -> str | None:
    """Locate a toolchain executable, preferring ROCm's own copy over PATH."""
    rocm_bin = _rocm_llvm_bin()
    if rocm_bin:
        found = shutil.which(name, path=rocm_bin)
        if found:
            return found

    return shutil.which(name)


def _parse_arches(lines: list[str]) -> list[str]:
    """Extract gfx target names from a -mcpu=help listing."""
    arches = []
    for line in lines:
        match = _ARCH_PATTERN.match(line)
        if match and len(match.group(1)) >= _MIN_ARCH_LEN:
            arches.append(match.group(1))

    return arches


# camelCase is kept because external build scripts import this name.
def enumArch(min_arch: str) -> list[str]:
    """Return list of AMD GPU architectures >= min_arch, or [] if none found."""
    min_value = to_number(min_arch)

    for name, args in _ENUM_COMMANDS:
        tool = _find_tool(name)
        if not tool:
            continue

        result = _run([tool] + args)
        if result is None:
            continue

        # Both tools print the listing to stderr on some versions.
        lines = result.stdout.splitlines() + result.stderr.splitlines()
        arches = [a for a in _parse_arches(lines) if min_value <= to_number(a)]

        supported = _device_library_arches()
        if supported:
            dropped = [a for a in arches if a not in supported]
            if dropped:
                print(
                    "note: skipping targets without a ROCm device library: "
                    + " ".join(dropped),
                    file=sys.stderr,
                )
            arches = [a for a in arches if a in supported]

        if arches:
            return arches

        print(f"warning: {tool} listed no architecture >= {min_arch}", file=sys.stderr)

    print(
        "warning: no working LLVM toolchain found to enumerate architectures",
        file=sys.stderr,
    )

    return []
