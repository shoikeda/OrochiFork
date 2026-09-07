#!/bin/sh
# Shared body for the unittest_*.sh runners.
# Cleans the kernel cache, generates bitcodes, and runs the test suite.
# Usage: sh _run_unittest.sh <target> <bitcode-script|none> <gtest-filter> [config] [extra UnitTest args...]

set -e

# Every path below is relative to the scripts directory.
cd "$(dirname "$0")"

TARGET=$1
BITCODE=$2
FILTER=$3
shift 3

. ./_config.sh "$1"
# _config.sh consumes the configuration; everything after it goes to the test binary.
if [ $# -gt 0 ]; then shift; fi

rm -rf cache

if [ "$BITCODE" != none ]; then
    # Checked here so a missing generator reports its own name instead of a bare
    # "not found" from the subshell below.
    if [ ! -f "../UnitTest/bitcodes/$BITCODE" ]; then
        echo "error: bitcode generator not found: UnitTest/bitcodes/$BITCODE" >&2
        exit 1
    fi
    # Subshell keeps the working directory put for the test run below.
    ( cd ../UnitTest/bitcodes && sh "$BITCODE" )
fi

# The filter is quoted so the shell cannot glob its '*' against the cwd.
"${UNITTEST_BIN}" "$@" --gtest_filter="$FILTER" --gtest_output="xml:../result_${TARGET}.xml"
