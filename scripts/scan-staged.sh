#!/usr/bin/env bash
set -uo pipefail

added=$(git diff --cached --unified=0 | grep -E '^\+[^+]' || true)
files=$(git diff --cached --name-only)
fail=0

secret_re='-----BEGIN [A-Z ]*PRIVATE KEY-----|sk-[A-Za-z0-9]{16,}|sk_(live|test)_[A-Za-z0-9]{16,}|gh[pousr]_[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16}|xox[baprs]-[A-Za-z0-9-]{10,}|Bearer[[:space:]]+[A-Za-z0-9._-]{16,}'

if printf '%s\n' "$added" | grep -nEi -- "$secret_re"; then
  echo 'Possible secrets found in staged additions.' >&2
  fail=1
fi

if printf '%s\n' "$files" | grep -E '(^|/)\.env([.][A-Za-z0-9_-]+)?$' | grep -vE '\.(sample|template|example|dist)$'; then
  echo 'Real .env file staged.' >&2
  fail=1
fi

forbidden_re='(^|/)(auth\.json|history\.jsonl|installation_id|shell_snapshots|sessions|memories|mcp-oauth-locks)(/|$)|\.sqlite(-shm|-wal)?$|plugins/cache'
if printf '%s\n' "$files" | grep -E -- "$forbidden_re"; then
  echo 'Forbidden runtime or private path staged.' >&2
  fail=1
fi

if [ "$fail" -ne 0 ]; then
  exit 1
fi

echo 'No secrets or forbidden runtime data found in staged files.'
