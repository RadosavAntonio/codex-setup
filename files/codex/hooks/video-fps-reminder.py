#!/usr/bin/env python3
import json
import re
import sys

data = json.load(sys.stdin)
message = data.get("prompt", "")
is_video = bool(re.search(r"(?i)(analys[ei]|watch|summariz|process|review|transcript)", message)) and bool(re.search(r"(?i)(\.(mp4|mov|avi|mkv|webm)|youtube\.com|youtu\.be|video)", message))
has_fps = bool(re.search(r"(?i)(\bfps\b|\d+\s*fps|frame.{0,2}rate|frames.{0,3}per.{0,3}second)", message))
if is_video and not has_fps:
    print(json.dumps({"hookSpecificOutput": {"hookEventName": "UserPromptSubmit", "additionalContext": "The user wants video analysis but did not specify FPS. Ask how many FPS to use before calling video tools; offer auto as the default."}}))
