#!/usr/bin/env bash
set -uo pipefail
input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // ""' 2>/dev/null)

scan=$(printf '%s' "$cmd" | python3 -c '
import re, sys
s = sys.stdin.read()
out = []
i = 0
opener = re.compile(r"<<-?\s*([\"'"'"']?)([A-Za-z_][A-Za-z0-9_]*)\1")
interpreters = re.compile(r"(?:^|[|;&(]\s*|\s)(bash|sh|zsh|python[0-9.]*|node|ruby|perl)\s*$")
while True:
    match = opener.search(s, i)
    if not match:
        out.append(s[i:])
        break
    out.append(s[i:match.end()])
    closer = re.compile(r"\n" + re.escape(match.group(2)) + r"(?=\n|$)")
    close_match = closer.search(s, match.end())
    if not close_match:
        out.append(s[match.end():])
        break
    if interpreters.search(s[:match.start()]):
        out.append(s[match.end():close_match.end()])
    i = close_match.end()
print("".join(out), end="")
' 2>/dev/null)
[ -n "$scan" ] || scan="$cmd"

reason=""
case "$scan" in
  *"git push"*--force*|*"git push"*" -f"*) reason="force push can overwrite remote history" ;;
esac
case "$scan" in
  *"git reset"*--hard*) reason="${reason:+$reason; }git reset --hard discards uncommitted work" ;;
esac
case "$scan" in
  *"git clean"*"-f"*|*"git clean"*"--force"*) reason="${reason:+$reason; }git clean permanently deletes untracked files" ;;
esac
case "$scan" in
  *"git branch"*-D*) reason="${reason:+$reason; }git branch -D can lose commits" ;;
esac
case "$scan" in
  *"git checkout --"*|*"git checkout ."*|*"git restore"*) reason="${reason:+$reason; }command discards uncommitted changes" ;;
esac
case "$scan" in
  *"rm -rf"*|*"rm -fr"*|*"rm -r -f"*|*"rm -f -r"*|*"rm --recursive --force"*|*"rm --force --recursive"*) reason="${reason:+$reason; }recursive forced removal is irreversible" ;;
esac
case "$scan" in
  *"--no-verify"*|*"--no-gpg-sign"*) reason="${reason:+$reason; }command bypasses verification or signing" ;;
esac
if [ -n "$reason" ]; then
  printf 'BLOCKED: destructive or irreversible command (%s). Confirm the exact target and intent with the user before retrying.\n' "$reason" >&2
  exit 2
fi
