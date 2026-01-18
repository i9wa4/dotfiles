#!/bin/bash
# status-reminder.sh
#
# Hook script to remind Orchestrator to update status file.
# Shows reminder after tool use.
#
# Usage in settings.json:
# {
#   "hooks": {
#     "PostToolUse": [
#       {
#         "matcher": ".*",
#         "hooks": [
#           {
#             "type": "command",
#             "command": "bash ~/ghq/github.com/i9wa4/dotfiles/config/scripts/status-reminder.sh"
#           }
#         ]
#       }
#     ]
#   }
# }
#
# Hook receives JSON on stdin with tool_name and tool_input.
# Exit 0 to continue.

set -euo pipefail

# Only remind for orchestrator role
if [[ "${CLAUDE_ROLE:-}" != "orchestrator" ]]; then
  exit 0
fi

# Read tool input from stdin
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

# Skip reminder for status file operations (avoid infinite loop)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
if [[ -n "$FILE_PATH" && "$FILE_PATH" == *"status-pane"* ]]; then
  exit 0
fi

# Skip reminder for simple read operations
case "$TOOL_NAME" in
Read | Glob | Grep)
  # Only remind after significant operations
  exit 0
  ;;
esac

# Show reminder after tool use
echo "REMINDER: Update .i9wa4/status-pane if task status changed"

exit 0
