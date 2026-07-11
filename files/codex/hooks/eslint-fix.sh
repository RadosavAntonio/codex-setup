#!/usr/bin/env bash
# PostToolUse(Edit|Write|apply_patch): best effort eslint --fix for edited JS/TS files.
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

printf '%s\n' "$files" | while IFS= read -r f; do
  case "$f" in
    *.ts|*.tsx|*.js|*.jsx|*.cjs|*.mjs) ;;
    *) continue ;;
  esac
  [ -f "$f" ] || continue

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
  "$eslint" --fix --no-error-on-unmatched-pattern "$f" >/dev/null 2>&1 || true
done

exit 0
