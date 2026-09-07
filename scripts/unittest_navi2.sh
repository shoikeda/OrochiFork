#!/bin/sh
# Run Orochi unit tests for Navi 2 (Linux)
# Usage: ./unittest_navi2.sh [Debug|DebugFast|RelWithDebInfo|Release] [extra UnitTest args...]

exec sh "$(dirname "$0")/_run_unittest.sh" navi2 generate_bitcodes.sh '-*link*:*getErrorString*' "$@"
