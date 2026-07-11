#!/usr/bin/env bash
# PreToolUse(Bash) hook: block git commit when staged additions contain
# high confidence secrets or a real .env file.
set -uo pipefail

input=$(cat)
cmd=$(printf '%s' "$input" | {{HOME}}/.codex/hooks/_extract_command.sh 2>/dev/null || true)

case "$cmd" in
  *"git commit"*) ;;
  *) exit 0 ;;
esac

added=$(git diff --cached --unified=0 2>/dev/null | grep -E '^\+[^+]' || true)
findings=""

secret_re='-----BEGIN [A-Z ]*PRIVATE KEY-----|sk-[A-Za-z0-9]{16,}|sk_(live|test)_[A-Za-z0-9]{16,}|gh[pousr]_[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16}|xox[baprs]-[A-Za-z0-9-]{10,}|eyJ[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{6,}'
hits=$(printf '%s' "$added" | grep -nEi -- "$secret_re" | head -20 || true)
if [ -n "$hits" ]; then
  findings="${findings}Secret-like strings in staged additions:\n${hits}\n\n"
fi

envfiles=$(git diff --cached --name-only --diff-filter=A 2>/dev/null \
  | grep -E '(^|/)\.env([.][A-Za-z0-9_-]+)?$' \
  | grep -vE '\.(sample|template|example|dist)$' || true)
if [ -n "$envfiles" ]; then
  findings="${findings}Staged .env file(s):\n${envfiles}\n"
fi

if [ -n "$findings" ]; then
  printf 'BLOCKED: possible secrets in staged commit.\n\n%b\nRedact or unstage them before committing. If this is a genuine false positive, run the commit yourself in the terminal.\n' "$findings" >&2
  exit 2
fi

exit 0
