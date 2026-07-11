#!/usr/bin/env bash
# PreToolUse(Bash) hook: ask for dependency research before adding packages.
set -uo pipefail

input=$(cat)
cmd=$(printf '%s' "$input" | {{HOME}}/.codex/hooks/_extract_command.sh 2>/dev/null || true)

has_pkg() {
  local s="$1" rest tok
  case "$s" in
    *"yarn add "*)     rest="${s#*yarn add }" ;;
    *"pnpm add "*)     rest="${s#*pnpm add }" ;;
    *"npm install "*)  rest="${s#*npm install }" ;;
    *"npm i "*)        rest="${s#*npm i }" ;;
    *"npm add "*)      rest="${s#*npm add }" ;;
    *) return 1 ;;
  esac

  for tok in $rest; do
    case "$tok" in
      "&&"|";"|"|") break ;;
      -*) ;;
      *) return 0 ;;
    esac
  done
  return 1
}

if has_pkg "$cmd"; then
  cat <<'JSON'
{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":"Dependency addition detected. Run $check-dep first: check bundle size, maintenance, React Native native linking, compatibility, and lighter alternatives before approving."}}
JSON
fi

exit 0
