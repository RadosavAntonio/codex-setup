#!/usr/bin/env bash
# PostToolUse(Edit|Write|apply_patch): run eslint --fix on edited JS/TS files.
set -uo pipefail

input=$(cat)

files=$(
  {
    printf '%s' "$input" | jq -r '
      [
        .. | objects | .file_path?,
        .. | objects | .filePath?,
        .. | objects | .path?
      ]
      | .[]?
      | select(type == "string")
    ' 2>/dev/null

    printf '%s' "$input" | jq -r '
      .. | strings | select(test("\\*\\*\\* (Add|Update) File: "))
    ' 2>/dev/null | sed -nE 's/^\*\*\* (Add|Update) File: (.*)$/\2/p'
  } | sort -u
)

[ -n "$files" ] || exit 0

fail=0
while IFS= read -r f; do
  case "$f" in
    *.ts|*.tsx|*.js|*.jsx|*.cjs|*.mjs) ;;
    *) continue ;;
  esac
  [ -f "$f" ] || continue

  f=$(cd "$(dirname "$f")" 2>/dev/null && printf '%s/%s\n' "$PWD" "$(basename "$f")") || continue

  dir=$(dirname "$f")
  eslint=""
  while [ "$dir" != "/" ] && [ -n "$dir" ]; do
    if [ -x "$dir/node_modules/.bin/eslint" ]; then
      eslint="$dir/node_modules/.bin/eslint"
      break
    fi
    dir=$(dirname "$dir")
  done
  [ -n "$eslint" ] || continue
  if ! "$eslint" --fix --no-error-on-unmatched-pattern "$f"; then
    printf 'ESLint fix failed: %s\n' "$f" >&2
    fail=1
  fi
done <<< "$files"

if [ "$fail" -eq 1 ]; then
  exit 2
fi

exit 0
