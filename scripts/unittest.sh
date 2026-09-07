#!/bin/sh
# Run Orochi unit tests (Linux)
# Usage: ./unittest.sh [Debug|DebugFast|RelWithDebInfo|Release] [extra UnitTest args...]

exec sh "$(dirname "$0")/_run_unittest.sh" default generate_bitcodes.sh '-*link_bundledBc*' "$@"
