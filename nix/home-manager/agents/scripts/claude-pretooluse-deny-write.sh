#!/usr/bin/env bash
# claude-pretooluse-deny-write.sh - Role-based write deny using tmux pane title (role name)
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
set -o errexit
set -o nounset
set -o pipefail
set -o posix

# Read JSON from stdin
INPUT=$(cat)

# Extract tool_name from JSON
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)

# Get role name from tmux pane title
if [[ -n ${TMUX_PANE:-} ]]; then
  ROLE_NAME=$(tmux display-message -t "$TMUX_PANE" -p '#{pane_title}' 2>/dev/null || true)
else
  ROLE_NAME=""
fi

# Extract file_path from tool_input
get_file_path() {
  echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null
}

# ============================================================
# Role-based check (pane title / role name)
# ============================================================

# Block only when role name is set AND not starting with "worker"
# (not in tmux or no pane title = normal use, allow all)
if [[ -n $ROLE_NAME ]] && case "$ROLE_NAME" in worker* | agent) false ;; *) true ;; esac then
  case "$TOOL" in
  Write | Edit | NotebookEdit)
    FILE_PATH=$(get_file_path)

    if [[ -n $FILE_PATH && $FILE_PATH == "$HOME/.local/state/tmux-a2a-postman/"* ]]; then
      : # Allow writes to postman state directory
    elif [[ -n $FILE_PATH && $FILE_PATH == "$HOME/.local/state/mkmd/"* ]]; then
      : # Allow writes to mkmd state directory
    elif [[ -n $FILE_PATH && $FILE_PATH == "/tmp/"* ]]; then
      : # Allow writes to /tmp/ directory
    elif [[ -n $FILE_PATH && -n ${SUBDIR:-} && $FILE_PATH == "${SUBDIR}/"* ]]; then
      : # Allow writes to SUBDIR directory
    else
      REASON="🚫 BLOCKED: ${ROLE_NAME} is READONLY. Only worker can edit files."$'\n'"💡 Alternative: Delegate task to worker via tmux-a2a-postman."
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
