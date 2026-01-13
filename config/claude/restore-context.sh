#!/usr/bin/env bash
# reload CLAUDE.md after autocompaction
CLAUDE_MD="${CLAUDE_CONFIG_DIR}/CLAUDE.md"

if [[ -f $CLAUDE_MD ]]; then
  content=$(cat "$CLAUDE_MD")
  escaped=$(echo "$content" | jq -Rs .)
  echo "{\"userMessage\": $escaped}"
fi
