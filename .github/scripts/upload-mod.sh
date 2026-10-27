#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../.."

status=$(bash .github/scripts/check-published-version.sh)
if [ "$status" = "published" ]; then
  echo "Skipping upload."
  exit 0
fi
if [ "$status" != "new" ]; then
  echo "Unexpected portal check result" >&2
  exit 1
fi

name=$(jq -r '.name' info.json)
version=$(jq -r '.version' info.json)
if [ -z "$name" ] || [ "$name" = "null" ] || [ -z "$version" ] || [ "$version" = "null" ]; then
  echo "info.json must contain name and version" >&2
  exit 1
fi

if [ -z "${FACTORIO_API_KEY:-}" ]; then
  echo "FACTORIO_API_KEY is required" >&2
  exit 1
fi

archive="dist/${name}_${version}.zip"
if [ ! -f "$archive" ]; then
  echo "Missing ${archive}. Run create-mod-zip.sh first." >&2
  exit 1
fi

init_body=$(mktemp)
init_code=$(curl -sS -o "$init_body" -w "%{http_code}" \
  -X POST \
  -H "Authorization: Bearer ${FACTORIO_API_KEY}" \
  -F "mod=${name}" \
  https://mods.factorio.com/api/v2/mods/releases/init_upload)

if [ "$init_code" -lt 200 ] || [ "$init_code" -ge 300 ]; then
  echo "init_upload failed with HTTP ${init_code}" >&2
  cat "$init_body" >&2
  exit 1
fi

upload_url=$(jq -r '.upload_url // empty' "$init_body")
if [ -z "$upload_url" ]; then
  echo "init_upload did not return upload_url" >&2
  cat "$init_body" >&2
  exit 1
fi

upload_body=$(mktemp)
upload_code=$(curl -sS -o "$upload_body" -w "%{http_code}" \
  -X POST \
  -H "Authorization: Bearer ${FACTORIO_API_KEY}" \
  -F "file=@${archive}" \
  "$upload_url")

if [ "$upload_code" -lt 200 ] || [ "$upload_code" -ge 300 ]; then
  echo "upload failed with HTTP ${upload_code}" >&2
  cat "$upload_body" >&2
  exit 1
fi

echo "Published ${name} ${version}"
