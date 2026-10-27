#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../.."

if command -v lua5.4 >/dev/null 2>&1; then
  lua5.4 tests/run.lua
elif command -v lua >/dev/null 2>&1; then
  lua tests/run.lua
else
  echo "Lua is required to run the unit tests" >&2
  exit 1
fi
