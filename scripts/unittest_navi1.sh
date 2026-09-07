#!/bin/sh
# Run Orochi unit tests for Navi 1 (Linux)
# Usage: ./unittest_navi1.sh [Debug|DebugFast|RelWithDebInfo|Release] [extra UnitTest args...]

exec sh "$(dirname "$0")/_run_unittest.sh" navi1 generate_bitcodes.sh '-*link*:*getErrorString*' "$@"
