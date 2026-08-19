#!/bin/sh
skill="{{HOME}}/.codex/skills/caveman/SKILL.md"
[ -f "$skill" ] || exit 0
awk '
  NR==1 && $0=="---" { infm=1; next }
  infm && $0=="---" { infm=0; next }
  infm { next }
  { print }
' "$skill"
