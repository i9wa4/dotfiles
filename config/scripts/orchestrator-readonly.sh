#!/bin/bash
# orchestrator-readonly.sh
#
# Hook script to enforce READONLY mode for Orchestrator.
# Blocks Edit, Write, NotebookEdit tools when CLAUDE_ROLE=orchestrator.
#
# Usage in settings.json:
# {
#   "hooks": {
#     "PreToolUse": [
#       {
#         "matcher": "Edit|Write|NotebookEdit",
#         "hooks": [
#           {
#             "type": "command",
#             "command": "bash ${CLAUDE_CONFIG_DIR}/scripts/orchestrator-readonly.sh"
#           }
#         ]
#       }
#     ]
#   }
# }
#
# Hook receives JSON on stdin with tool_name and tool_input.
# Exit 0 to allow, exit 2 to block with message on stdout.

set -euo pipefail

# Only enforce for orchestrator role
if [[ "${CLAUDE_ROLE:-}" != "orchestrator" ]]; then
  exit 0
fi

# Read tool input from stdin
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Allow writes to .i9wa4/ directory (plans, reports, status)
if [[ -n "$FILE_PATH" && "$FILE_PATH" == *".i9wa4/"* ]]; then
  exit 0
fi

# Allow writes to /tmp/ directory
if [[ -n "$FILE_PATH" && "$FILE_PATH" == "/tmp/"* ]]; then
  exit 0
fi

# Block Edit, Write, NotebookEdit for project files
case "$TOOL_NAME" in
Edit | Write | NotebookEdit)
  echo "BLOCKED: Orchestrator is READONLY. Delegate to Worker for: $TOOL_NAME"
  echo ""
  echo "Use Worker communication to delegate this task:"
  echo "  [WORKER capability=WRITABLE]"
  echo "  {task description}"
  echo ""
  echo "See: references/worker-comm.md"
  exit 2
  ;;
esac

exit 0
