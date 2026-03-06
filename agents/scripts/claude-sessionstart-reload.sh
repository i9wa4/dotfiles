#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
set -o posix

# sessionstart-reload.sh - CLAUDE.md context reloader
#
# Force Claude to reload CLAUDE.md after compaction/resume.
# Outputs CLAUDE.md content in additionalContext using jq for JSON escape.
#
# Hook: SessionStart
# Matcher: compact|resume|clear
#
# Input (stdin JSON):
#   { "hook_event_name": "SessionStart", "source": "compact|resume|clear", ... }
#
# Output:
#   JSON with hookSpecificOutput containing additionalContext

CLAUDE_MD="${CLAUDE_CONFIG_DIR}/CLAUDE.md"

if [[ -f $CLAUDE_MD ]]; then
  CONTENT=$(cat "$CLAUDE_MD" | jq -Rs .)
  echo "{\"hookSpecificOutput\":{\"hookEventName\":\"SessionStart\",\"additionalContext\":$CONTENT}}"
else
  echo '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"CLAUDE.md not found"}}'
fi
