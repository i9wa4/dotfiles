#!/bin/bash
# worker-reminder.sh
#
# Hook script to remind Orchestrator to delegate to Workers.
# Shows warning (not blocking) when using Read/Glob/Grep/Task tools.
#
# Usage in settings.json:
# {
#   "hooks": {
#     "PreToolUse": [
#       {
#         "matcher": "Read|Glob|Grep|Task",
#         "hooks": [
#           {
#             "type": "command",
#             "command": "bash ~/ghq/github.com/i9wa4/dotfiles/config/scripts/worker-reminder.sh"
#           }
#         ]
#       }
#     ]
#   }
# }
#
# Hook receives JSON on stdin with tool_name and tool_input.
# Exit 0 to allow (with optional warning on stdout).

set -euo pipefail

# Only remind for orchestrator role
if [[ "${CLAUDE_ROLE:-}" != "orchestrator" ]]; then
  exit 0
fi

# Read tool input from stdin
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

# Extract file path or pattern depending on tool
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // .tool_input.pattern // empty')

# Skip warning for .i9wa4/ files (communication, status, plans)
if [[ -n "$FILE_PATH" && "$FILE_PATH" == *".i9wa4/"* ]]; then
  exit 0
fi

# Skip warning for /tmp/ files (communication files)
if [[ -n "$FILE_PATH" && "$FILE_PATH" == "/tmp/"* ]]; then
  exit 0
fi

# Skip warning for worker-comm directory
if [[ -n "$FILE_PATH" && "$FILE_PATH" == *"worker-comm"* ]]; then
  exit 0
fi

# Show reminder for investigation tools
case "$TOOL_NAME" in
Read | Glob | Grep | Task)
  echo "REMINDER: Consider delegating to Worker"
  echo "  - codex worker: Investigation, consultation"
  echo "  - claude worker: Implementation"
  echo "Continue if direct operation is necessary."
  ;;
esac

# Always allow (exit 0), just remind
exit 0
