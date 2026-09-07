#!/usr/bin/env python3
"""Stringify GPU kernel source files into C++ string literals.

Reads kernel source files and converts them into C++ const char* variables
that can be compiled directly into the binary.

Usage:
    python3 stringify.py <kernel_file>
"""
import argparse
import re
import sys
from pathlib import Path
from typing import Final

# Every baked kernel targets HIP; the CL/Metal variants this script once
# branched on have no inputs anywhere in the tree.
_API: Final = "hip"

# Includes whose contents are pulled in textually instead of being compiled
# separately. No source in the tree currently uses one.
_INLINE_MARKERS: Final = ("inl.cl", "inl.metal", "inl.cu")

_SOURCE_SUFFIXES: Final = (".cl", ".cu", ".metal", ".h")

_INCLUDE_PATH: Final = re.compile(r'#include\s*[<"]([^>"]+)[>"]')


def read_lines(path: Path, base_dir: Path) -> list[str]:
    """Read a kernel file, inlining marked includes and escaping for C++."""
    out: list[str] = []

    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()

        if line.startswith("//"):
            continue

        if any(marker in line for marker in _INLINE_MARKERS):
            match = _INCLUDE_PATH.search(line)
            if match:
                # The directive is replaced by the file it names, so it must not
                # also be emitted. Only the basename is honoured, resolved
                # against base_dir rather than the including file's directory.
                out.extend(read_lines(base_dir / Path(match.group(1)).name, base_dir))
                continue

        escaped = line.replace('"', '\\"').replace("'", "\\'")
        out.append(f'"{escaped}\\n"')

    return out


def stringify(path: Path, string_name: str, base_dir: Path) -> str:
    """Render one kernel file as a C++ string literal variable."""
    body = "".join(f"{line}\n" for line in read_lines(path, base_dir))
    return f"static const char* {string_name}= \\\n{body};"


def main() -> int:
    parser = argparse.ArgumentParser(description="Stringify a kernel source file.")
    parser.add_argument("kernel_file", type=Path, help="kernel source to stringify")
    args = parser.parse_args()

    source: Path = args.kernel_file
    if not source.is_file():
        print(f"error: no such file: {source}", file=sys.stderr)
        return 1
    if source.suffix not in _SOURCE_SUFFIXES:
        print(f"error: not a kernel source: {source}", file=sys.stderr)
        return 1

    sys.stdout.reconfigure(encoding="utf-8")
    try:
        rendered = stringify(source, f"{_API}_{source.stem}", Path("./"))
    except OSError as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1

    print(rendered)
    return 0


if __name__ == "__main__":
    sys.exit(main())
