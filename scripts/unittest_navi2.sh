#!/bin/sh
# Run Orochi unit tests for Navi 2 (Linux)
# Usage: ./unittest_navi2.sh [Debug|DebugFast|RelWithDebInfo|Release] [extra UnitTest args...]

set -e

# Every path below is relative to this script's directory.
cd "$(dirname "$0")"
. ./_config.sh "$1"
# _config.sh consumes the configuration; everything after it goes to the test binary.
if [ $# -gt 0 ]; then shift; fi

rm -rf cache
cd ../UnitTest/bitcodes && ./generate_bitcodes.sh && cd ../../scripts
"${UNITTEST_BIN}" "$@" --gtest_filter=-*link*:*getErrorString* --gtest_output=xml:../result.xml
