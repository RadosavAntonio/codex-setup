#!/usr/bin/env bash
set -uo pipefail
cat >/dev/null 2>&1 || true
repo=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
cd "$repo" 2>/dev/null || exit 0
files=$( {
  git diff --name-only --diff-filter=ACM 2>/dev/null
  git diff --cached --name-only --diff-filter=ACM 2>/dev/null
  git ls-files --others --exclude-standard 2>/dev/null
} | grep -Ei '\.(ts|tsx|js|jsx)$' | sort -u )
[ -z "$files" ] && exit 0

out=""
fail=0
eslint="$repo/node_modules/.bin/eslint"
tsc="$repo/node_modules/.bin/tsc"
jest="$repo/node_modules/.bin/jest"

if [ -x "$eslint" ]; then
  emsg=$(printf '%s\n' "$files" | tr '\n' '\0' | xargs -0 "$eslint" --no-error-on-unmatched-pattern 2>&1) || {
    fail=1
    out="${out}ESLint on changed files:\n${emsg}\n\n"
  }
fi

if [ -x "$tsc" ]; then
  tmsg=$("$tsc" --noEmit 2>&1) || true
  pat=$(printf '%s\n' "$files" | sed 's/[.]/\\./g' | paste -sd'|' -)
  if [ -n "$pat" ]; then
    myerr=$(printf '%s\n' "$tmsg" | grep -E "($pat)\(" || true)
    if [ -n "$myerr" ]; then
      fail=1
      out="${out}TypeScript errors in changed files:\n${myerr}\n\n"
    fi
  fi
fi

if [ -x "$jest" ]; then
  jmsg=$(printf '%s\n' "$files" | tr '\n' '\0' | xargs -0 "$jest" --findRelatedTests --passWithNoTests 2>&1) || {
    fail=1
    out="${out}Jest related tests:\n${jmsg}\n\n"
  }
fi

if [ "$fail" -eq 1 ]; then
  printf 'Verification failed on changed files:\n\n%b\nFix these failures before completing the task.\n' "$out" >&2
  exit 2
fi
