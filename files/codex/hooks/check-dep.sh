#!/usr/bin/env bash
set -uo pipefail
input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // ""' 2>/dev/null)

has_package_argument() {
  local command="$1" remainder token
  case "$command" in
    *"yarn add "*) remainder="${command#*yarn add }" ;;
    *"pnpm add "*) remainder="${command#*pnpm add }" ;;
    *"npm install "*) remainder="${command#*npm install }" ;;
    *"npm i "*) remainder="${command#*npm i }" ;;
    *"npm add "*) remainder="${command#*npm add }" ;;
    *) return 1 ;;
  esac

  for token in $remainder; do
    case "$token" in
      "&&"|";"|"|") break ;;
      -*) ;;
      *) return 0 ;;
    esac
  done
  return 1
}

if has_package_argument "$cmd"; then
  printf '%s\n' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":"A new dependency is being added. Use the check-dep skill first, assess maintenance, size, native linking, security, and alternatives, then obtain user approval before installation."}}'
fi
