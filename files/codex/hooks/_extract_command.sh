#!/usr/bin/env bash
set -uo pipefail

jq -r '
  [
    .tool_input.command?,
    .input.command?,
    .arguments.command?,
    .tool.arguments.command?,
    .params.command?,
    .command?
  ]
  | map(select(type == "string" and length > 0))
  | .[0] // ""
'
