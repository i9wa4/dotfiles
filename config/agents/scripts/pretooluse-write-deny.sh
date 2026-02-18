#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
set -o posix

# pretooluse-write-deny.sh - Role-based write deny using tmux pane title (role name)
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

# Get role name from tmux pane title
ROLE_NAME=$(tmux display-message -p '#{pane_title}' 2>/dev/null || true)

# DEBUG: Output environment info to file
echo "DEBUG deny.sh: $(date +%Y%m%d-%H%M%S) ROLE_NAME=${ROLE_NAME:-UNSET} TOOL=${TOOL:-UNSET}" >>/tmp/deny-debug.log

# Extract file_path from tool_input
get_file_path() {
  echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null
}

# ============================================================
# Role-based check (pane title / role name)
# ============================================================

# Block only when role name is set AND not starting with "worker"
# (not in tmux or no pane title = normal use, allow all)
if [[ -n $ROLE_NAME && $ROLE_NAME != worker && $ROLE_NAME != agent ]]; then
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
      REASON="🚫 BLOCKED: ${ROLE_NAME} is READONLY. Only worker* can edit files."$'\n'"💡 Alternative: Delegate task to worker via postman"
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
