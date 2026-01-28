#!/usr/bin/env bash
# deny.sh - Role-based deny for A2A_NODE mode
#
# Blocks Edit/Write/NotebookEdit for non-worker agents.
# Pattern-based deny is handled by settings.json deny list.
#
# Environment variables (from Claude Code PreToolUse hook):
#   TOOL_NAME  - Tool name (Bash, Read, Write, Edit, NotebookEdit)
#   TOOL_INPUT - JSON input parameters
#
# Exit codes:
#   0 - Allow
#   2 - Block

set -euo pipefail

TOOL="${TOOL_NAME:-}"
INPUT="${TOOL_INPUT:-}"

# Extract file_path from tool input
get_file_path() {
  echo "$INPUT" | jq -r '.file_path // empty' 2>/dev/null
}

# ============================================================
# Role-based check (A2A_NODE mode)
# ============================================================

if [[ -n ${A2A_NODE:-} && ${A2A_NODE} != worker* ]]; then
  case "$TOOL" in
  Write | Edit | NotebookEdit)
    FILE_PATH=$(get_file_path)

    # Allow writes to .i9wa4/ directory
    if [[ -n $FILE_PATH && ($FILE_PATH == ".i9wa4/"* || $FILE_PATH == *"/.i9wa4/"*) ]]; then
      : # Allow
    # Allow writes to .postman/ directory
    elif [[ -n $FILE_PATH && ($FILE_PATH == ".postman/"* || $FILE_PATH == *"/.postman/"*) ]]; then
      : # Allow
    # Allow writes to /tmp/ directory
    elif [[ -n $FILE_PATH && $FILE_PATH == "/tmp/"* ]]; then
      : # Allow
    else
      echo "🚫 BLOCKED: ${A2A_NODE} is READONLY. Only worker* can edit files." >&2
      echo "💡 Alternative: Send task to worker via postman" >&2
      exit 2
    fi
    ;;
  esac
fi

exit 0
