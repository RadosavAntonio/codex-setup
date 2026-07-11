#!/usr/bin/env python3
import json
import re
import sys

try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)

msg = (
    data.get("message")
    or data.get("prompt")
    or data.get("user_prompt")
    or data.get("input")
    or ""
)
if not isinstance(msg, str):
    msg = json.dumps(msg)

is_video = (
    bool(re.search(r"(?i)(analyse|analyze|watch|summariz|process|review|transcript)", msg))
    and bool(re.search(r"(?i)(\.(mp4|mov|avi|mkv|webm)|youtube\.com|youtu\.be|video)", msg))
) or bool(re.search(r"https?://(www\.)?(youtube\.com/watch|youtu\.be/)", msg))

has_fps = bool(re.search(r"(?i)(\bfps\b|\d+\s*fps|frame.{0,2}rate|frames.{0,3}per.{0,3}second)", msg))

if is_video and not has_fps:
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "UserPromptSubmit",
            "additionalContext": "REMINDER: User wants to analyse a video but has NOT specified FPS. Before calling video tools, ask: How many FPS would you like to use? (default: auto)"
        }
    }))
