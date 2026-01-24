#!/usr/bin/env bash
# deny-edit-write.sh
#
# Hook script to enforce READONLY mode for non-worker roles.
# Blocks Edit, Write, NotebookEdit tools for orchestrator and observer.
# All worker-* roles are allowed to edit files.
# Uses JSON output for better visibility to Claude.

set -euo pipefail

# A2A_PEER not set → normal mode (allow)
if [[ -z ${A2A_PEER:-} ]]; then
  exit 0
fi

# worker-* → writable (allow)
if [[ ${A2A_PEER} == worker-* ]]; then
  exit 0
fi

# All other roles (orchestrator, observer) → check for blocking

# Read tool input from stdin
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Allow writes to .i9wa4/ directory (project root only)
if [[ -n $FILE_PATH && ($FILE_PATH == ".i9wa4/"* || $FILE_PATH == *"/.i9wa4/"*) ]]; then
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
  "reason": "BLOCKED: ${A2A_PEER} is READONLY. Only worker-* can edit files."
}
JSONEOF
  exit 2
  ;;
esac

exit 0
