#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
set -o posix

# pretooluse-write-deny.sh - Role-based write deny for A2A_NODE mode
#
# Blocks Edit/Write/NotebookEdit for non-worker agents.
# Pattern-based deny is handled by settings.json deny list.
#
# Hook: PreToolUse
# Matcher: Write|Edit|NotebookEdit
#
# Input (stdin JSON):
#   {
#     "hook_event_name": "PreToolUse",
#     "tool_name": "Edit",
#     "tool_input": { "file_path": "...", ... }
#   }
#
# Output:
#   JSON with hookSpecificOutput containing permissionDecision and reason

# Read JSON from stdin
INPUT=$(cat)

# Extract tool_name from JSON
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)

# DEBUG: Output environment info to file
echo "DEBUG deny.sh: $(date +%Y%m%d-%H%M%S) A2A_NODE=${A2A_NODE:-UNSET} TOOL=${TOOL:-UNSET}" >>/tmp/deny-debug.log

# Extract file_path from tool_input
get_file_path() {
  echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null
}

# ============================================================
# Role-based check (A2A_NODE mode)
# ============================================================

# Block only when A2A_NODE is set AND not starting with "worker"
# (A2A_NODE unset = normal use, allow all)
if [[ -n ${A2A_NODE:-} && ${A2A_NODE} != worker* ]]; then
  case "$TOOL" in
  Write | Edit | NotebookEdit)
    FILE_PATH=$(get_file_path)

    if [[ -n $FILE_PATH && $FILE_PATH == "$HOME/.local/state/tmux-a2a-postman/"* ]]; then
      : # Allow writes to postman state directory
    elif [[ -n $FILE_PATH && $FILE_PATH == "$HOME/.local/state/claude/"* ]]; then
      : # Allow writes to claude state directory
    elif [[ -n $FILE_PATH && $FILE_PATH == "/tmp/"* ]]; then
      : # Allow writes to /tmp/ directory
    else
      REASON="🚫 BLOCKED: ${A2A_NODE} is READONLY. Only worker* can edit files."$'\n'"💡 Alternative: Send task to worker via postman"
      jq -n \
        --arg reason "$REASON" \
        '{
            hookSpecificOutput: {
              hookEventName: "PreToolUse",
              permissionDecision: "deny",
              permissionDecisionReason: $reason
            }
          }'
      exit 0
    fi
    ;;
  esac
fi

exit 0
