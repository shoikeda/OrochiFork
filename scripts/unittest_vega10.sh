#!/bin/sh
# Run Orochi unit tests for Vega 10 (Linux)
# Usage: ./unittest_vega10.sh [Debug|DebugFast|RelWithDebInfo|Release] [extra UnitTest args...]

exec sh "$(dirname "$0")/_run_unittest.sh" vega10 generate_bitcodes.sh '-*link*:*getErrorString*' "$@"
