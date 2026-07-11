#!/usr/bin/env bash
# Stop hook: verify changed JS/TS files with eslint and the full TypeScript check.
set -uo pipefail

cat >/dev/null 2>&1 || true

repo=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
cd "$repo" 2>/dev/null || exit 0

files=$(
  {
    git diff --name-only --diff-filter=ACM 2>/dev/null
    git diff --cached --name-only --diff-filter=ACM 2>/dev/null
    git ls-files --others --exclude-standard 2>/dev/null
  } | grep -Ei '\.(cjs|js|jsx|mjs|ts|tsx)$' | sort -u
)
[ -n "$files" ] || exit 0

eslint="$repo/node_modules/.bin/eslint"
tsc="$repo/node_modules/.bin/tsc"
out=""
fail=0

if [ -x "$eslint" ]; then
  emsg=$(printf '%s\n' "$files" | tr '\n' '\0' \
    | xargs -0 "$eslint" --no-error-on-unmatched-pattern 2>&1) || {
      fail=1
      out="${out}ESLint on changed files:\n${emsg}\n\n"
    }
fi

if [ -x "$tsc" ]; then
  if ! tmsg=$("$tsc" --noEmit 2>&1); then
    fail=1
    out="${out}tsc --noEmit:\n${tmsg}\n"
  fi
fi

if [ "$fail" -eq 1 ]; then
  printf 'Verification failed on files you changed:\n\n%b\nFix these before claiming done.\n' "$out" >&2
  exit 2
fi

exit 0
