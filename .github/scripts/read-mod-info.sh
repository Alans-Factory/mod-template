#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../.."

jq -e '
  (.name | type == "string" and length > 0) and
  (.version | type == "string" and length > 0) and
  (.title | type == "string" and length > 0) and
  (.author | type == "string" and length > 0) and
  (.factorio_version | type == "string" and length > 0)
' info.json > /dev/null

name=$(jq -r '.name' info.json)
version=$(jq -r '.version' info.json)

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "name=${name}" >> "$GITHUB_OUTPUT"
  echo "version=${version}" >> "$GITHUB_OUTPUT"
fi

echo "name=${name}"
echo "version=${version}"
