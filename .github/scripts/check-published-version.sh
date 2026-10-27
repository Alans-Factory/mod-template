#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../.."

name=$(jq -r '.name' info.json)
version=$(jq -r '.version' info.json)
if [ -z "$name" ] || [ "$name" = "null" ] || [ -z "$version" ] || [ "$version" = "null" ]; then
  echo "info.json must contain name and version" >&2
  exit 1
fi

set_publish() {
  if [ -n "${GITHUB_OUTPUT:-}" ]; then
    echo "publish=$1" >> "$GITHUB_OUTPUT"
  fi
}

portal_body=$(mktemp)
portal_url="https://mods.factorio.com/api/mods/$(jq -rn --arg name "$name" '$name | @uri')"
portal_code=$(curl -sS -H "Cache-Control: no-cache" -o "$portal_body" -w "%{http_code}" "$portal_url")

if [ "$portal_code" -eq 200 ]; then
  already_published=$(jq -r --arg version "$version" '
    if ((.releases // []) | map(.version) | index($version)) != null then "yes" else "no" end
  ' "$portal_body") || {
    echo "Mod portal response was not valid JSON" >&2
    cat "$portal_body" >&2
    exit 1
  }
  if [ "$already_published" = "yes" ]; then
    echo "${name} ${version} is already on the mod portal." >&2
    set_publish false
    echo "published"
    exit 0
  fi
elif [ "$portal_code" -ne 404 ]; then
  echo "Could not read published versions (HTTP ${portal_code})" >&2
  cat "$portal_body" >&2
  exit 1
fi

echo "${name} ${version} is not on the mod portal." >&2
set_publish true
echo "new"
