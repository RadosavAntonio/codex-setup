#!/bin/sh
[ -f /tmp/codex-nosound ] && exit 0
case "$1" in
  *approval-requested*) SOUND=/System/Library/Sounds/Ping.aiff ;;
  *) SOUND=/System/Library/Sounds/Glass.aiff ;;
esac
/usr/bin/afplay "$SOUND" >/dev/null 2>&1 || true
