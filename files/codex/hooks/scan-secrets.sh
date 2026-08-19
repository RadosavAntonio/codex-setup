#!/usr/bin/env bash
set -uo pipefail
input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // ""' 2>/dev/null)
case "$cmd" in *"git commit"*) ;; *) exit 0 ;; esac
added=$(git diff --cached --unified=0 2>/dev/null | grep -E '^\+[^+]' || true)
secret_re='-----BEGIN [A-Z ]*PRIVATE KEY-----|sk-[A-Za-z0-9]{16,}|sk_(live|test)_[A-Za-z0-9]{16,}|gh[pousr]_[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16}|xox[baprs]-[A-Za-z0-9-]{10,}|eyJ[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{6,}'
hits=$(printf '%s' "$added" | grep -nEi -- "$secret_re" | head -20 || true)
envfiles=$(git diff --cached --name-only --diff-filter=A 2>/dev/null | grep -E '(^|/)\.env([.][A-Za-z0-9_-]+)?$' | grep -vE '\.(sample|template|example|dist)$' || true)

findings=""
if [ -n "$hits" ]; then
  findings="${findings}Secret-like strings in staged additions:\n${hits}\n\n"
fi
if [ -n "$envfiles" ]; then
  findings="${findings}Staged environment files:\n${envfiles}\n"
fi

if [ -n "$hits" ] || [ -n "$envfiles" ]; then
  printf 'BLOCKED: possible secrets in staged changes.\n\n%b\nRun the scan-secrets skill, then redact or unstage findings before retrying.\n' "$findings" >&2
  exit 2
fi
