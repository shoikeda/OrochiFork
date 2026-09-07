#!/usr/bin/env python3
"""Generate kernel argument headers from HIP kernel source files.

Reads #include directives from a kernel header and produces a C++ array
of argument file references for runtime kernel compilation.

Usage:
    python3 genArgs.py <kernel_header.h>
"""
import argparse
import sys
from pathlib import Path
from typing import Final

# Every baked kernel targets HIP; the CL/Metal variants this script once
# branched on have no inputs anywhere in the tree.
_API: Final = "hip"


def gen_args(path: Path, out: list[str], includes: list[str]) -> None:
    """Emit the argument array for one kernel header, collecting its includes."""
    base_name = path.stem

    out.append("#if !defined(ORO_PP_LOAD_FROM_STRING)")
    out.append(f"\tstatic const char** {base_name}Args = 0;")
    out.append("#else")
    out.append(f"\tstatic const char* {base_name}Args[] = {{")

    includes.append(f"{base_name}Includes[] = {{")

    for line in path.read_text(encoding="utf-8").splitlines():
        if "#include" not in line:
            continue
        # Inlined sources are pulled in textually, and quoted includes are not
        # separate compile units, so neither becomes an argument entry.
        if f"inl.{_API}" in line or '"' in line:
            continue
        # Guards against '#include' appearing in a comment or macro.
        if "<" not in line or ">" not in line:
            continue

        included = line.split("<")[1].split(">")[0]
        includes.append(f'"{included}",')
        name = Path(included).name.split(f".{_API}")[0].split(".h")[0]
        out.append(f"{_API}_{name},")

    out.append(f"{_API}_{base_name}}};")
    out.append("#endif")


def main() -> int:
    parser = argparse.ArgumentParser(description="Generate a kernel argument header.")
    parser.add_argument("kernel_header", type=Path, help="kernel header to scan")
    args = parser.parse_args()

    if not args.kernel_header.is_file():
        print(f"error: no such file: {args.kernel_header}", file=sys.stderr)
        return 1

    out: list[str] = ["#pragma once", f"namespace {_API} {{"]
    includes: list[str] = ["static const char* "]

    gen_args(args.kernel_header, out, includes)
    includes.append("};")

    out.append("".join(includes))
    out.append(f"}}\t//namespace {_API}")

    sys.stdout.reconfigure(encoding="utf-8")
    print("\n".join(out))
    return 0


if __name__ == "__main__":
    sys.exit(main())
