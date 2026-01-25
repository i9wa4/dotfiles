#!/usr/bin/env bash

input=$(cat)

REMAINING=$(echo "$input" | jq -r '.context_window.remaining_percentage // 100' | cut -d. -f1)
MODEL=$(echo "$input" | jq -r '.model.display_name // .model.id // "?"')
VERSION=$(echo "$input" | jq -r '.version // "?"')

# Calculate context left until auto-compact
if [ -n "${CLAUDE_AUTOCOMPACT_PCT_OVERRIDE}" ]; then
  BUFFER=$((100 - CLAUDE_AUTOCOMPACT_PCT_OVERRIDE))
  LEFT=$((REMAINING - BUFFER))
  if [ "$LEFT" -lt 0 ]; then
    LEFT=0
  fi
  echo "${LEFT}% until compact | ${MODEL} | v${VERSION}"
else
  echo "${REMAINING}% left | ${MODEL} | v${VERSION}"
fi
