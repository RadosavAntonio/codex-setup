#!/usr/bin/env bash
set -uo pipefail
input=$(cat)
patch=$(printf '%s' "$input" | jq -r '.tool_input.command // ""' 2>/dev/null)
printf '%s\n' "$patch" | sed -nE 's/^\*\*\* (Add|Update) File: //p' | while IFS= read -r f; do
  case "$f" in *.ts|*.tsx|*.js|*.jsx|*.cjs|*.mjs) ;; *) continue ;; esac
  [ -f "$f" ] || continue
  dir=$(dirname "$f")
  while [ "$dir" != "/" ] && [ -n "$dir" ]; do
    if [ -x "$dir/node_modules/.bin/eslint" ]; then
      "$dir/node_modules/.bin/eslint" --fix --no-error-on-unmatched-pattern "$f" >/dev/null 2>&1 || true
      break
    fi
    dir=$(dirname "$dir")
  done
done
