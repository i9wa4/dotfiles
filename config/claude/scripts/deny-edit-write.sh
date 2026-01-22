#!/bin/bash
# orchestrator-readonly.sh
#
# Hook script to enforce READONLY mode for Orchestrator.
# Blocks Edit, Write, NotebookEdit tools when CLAUDE_ROLE=orchestrator.
# Uses JSON output for better visibility to Claude.

set -euo pipefail

# Only enforce for orchestrator role
if [[ ${CLAUDE_ROLE:-} != "orchestrator" ]]; then
  exit 0
fi

# Read tool input from stdin
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Allow writes to .i9wa4/ directory (plans, reports, status)
if [[ -n $FILE_PATH && $FILE_PATH == *".i9wa4/"* ]]; then
  exit 0
fi

# Allow writes to /tmp/ directory
if [[ -n $FILE_PATH && $FILE_PATH == "/tmp/"* ]]; then
  exit 0
fi

# Block Edit, Write, NotebookEdit for project files
case "$TOOL_NAME" in
Edit | Write | NotebookEdit)
  cat <<JSONEOF
{
  "decision": "block",
  "reason": "BLOCKED: Orchestrator is READONLY. Delegate to Worker for: ${TOOL_NAME}. Use [WORKER capability=WRITABLE] to delegate. See: references/worker-comm.md"
}
JSONEOF
  exit 2
  ;;
esac

exit 0
