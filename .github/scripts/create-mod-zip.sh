#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../.."

name=$(jq -r '.name' info.json)
version=$(jq -r '.version' info.json)
if [ -z "$name" ] || [ "$name" = "null" ] || [ -z "$version" ] || [ "$version" = "null" ]; then
  echo "info.json must contain name and version" >&2
  exit 1
fi

folder="${name}_${version}"
modfiles=".modfiles"
if [ ! -f "$modfiles" ]; then
  echo "Missing .modfiles" >&2
  exit 1
fi

shopt -s globstar nullglob
files=()
while IFS= read -r line || [ -n "$line" ]; do
  pattern="${line#"${line%%[![:space:]]*}"}"
  pattern="${pattern%"${pattern##*[![:space:]]}"}"
  [ -z "$pattern" ] && continue
  [[ "$pattern" == \#* ]] && continue

  if [[ "$pattern" == *[*?\[]* ]]; then
    # shellcheck disable=SC2206
    expanded=( $pattern )
  elif [ -e "$pattern" ]; then
    expanded=( "$pattern" )
  else
    expanded=()
  fi

  if [ "${#expanded[@]}" -eq 0 ]; then
    echo ".modfiles: nothing matched ${pattern}" >&2
    exit 1
  fi

  for path in "${expanded[@]}"; do
    if [ -d "$path" ]; then
      while IFS= read -r -d '' file; do
        files+=("$file")
      done < <(find "$path" -type f -print0)
    elif [ -f "$path" ]; then
      files+=("$path")
    fi
  done
done < "$modfiles"

if [ "${#files[@]}" -eq 0 ]; then
  echo ".modfiles did not match any files" >&2
  exit 1
fi

mkdir -p "dist/${folder}"
for file in "${files[@]}"; do
  mkdir -p "dist/${folder}/$(dirname "$file")"
  cp "$file" "dist/${folder}/$file"
done
(
  cd dist
  rm -f "${folder}.zip"
  zip -r "${folder}.zip" "${folder}"
)

echo "Created dist/${folder}.zip"
