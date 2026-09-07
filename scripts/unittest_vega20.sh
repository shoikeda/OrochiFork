#!/bin/sh
# Run Orochi unit tests for Vega 20 (Linux)
# Usage: ./unittest_vega20.sh [Debug|DebugFast|RelWithDebInfo|Release] [extra UnitTest args...]

exec sh "$(dirname "$0")/_run_unittest.sh" vega20 generate_bitcodes.sh '-*link*:*getErrorString*' "$@"
