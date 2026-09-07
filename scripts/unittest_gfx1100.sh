#!/bin/sh
# Run Orochi unit tests for gfx1100 (Linux)
# Usage: ./unittest_gfx1100.sh [Debug|DebugFast|RelWithDebInfo|Release] [extra UnitTest args...]

exec sh "$(dirname "$0")/_run_unittest.sh" gfx1100 generate_bitcodes_gfx1100.sh '-*link*:*getErrorString*' "$@"
