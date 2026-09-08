#!/bin/sh
# Run Orochi unit tests for gfx1102 (Linux)
# Usage: ./unittest_gfx1102.sh [Debug|DebugFast|RelWithDebInfo|Release] [extra UnitTest args...]

exec sh "$(dirname "$0")/_run_unittest.sh" gfx1102 generate_bitcodes.sh '-*link*:*getErrorString*' "$@"
