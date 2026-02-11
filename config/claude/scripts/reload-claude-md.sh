#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
set -o posix

# reload-claude-md.sh
#
# Hook script to force Claude to see CLAUDE.md after compaction/resume.
# Outputs CLAUDE.md content in additionalContext using jq for JSON escape.

CLAUDE_MD="${CLAUDE_CONFIG_DIR}/CLAUDE.md"

if [[ -f $CLAUDE_MD ]]; then
  CONTENT=$(cat "$CLAUDE_MD" | jq -Rs .)
  echo "{\"hookSpecificOutput\":{\"hookEventName\":\"SessionStart\",\"additionalContext\":$CONTENT}}"
else
  echo '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"CLAUDE.md not found"}}'
fi
