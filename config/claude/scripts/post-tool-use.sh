#!/usr/bin/env bash
# post-tool-use.sh
#
# PostToolUse hook for Orchestrator reminders.
# Combines status reminder and worker delegation reminder.

set -euo pipefail

# Only remind for orchestrator role
if [[ ${AGENT_ROLE:-} != "orchestrator" ]]; then
  exit 0
fi

# Read tool input from stdin
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // .tool_input.pattern // empty')

# Skip for .i9wa4/ files (project root only)
if [[ -n $FILE_PATH && ($FILE_PATH == ".i9wa4/"* || $FILE_PATH == *"/.i9wa4/"*) ]]; then
  exit 0
fi

# Skip for /tmp/ files
if [[ -n $FILE_PATH && $FILE_PATH == "/tmp/"* ]]; then
  exit 0
fi

# Skip for worker-comm directory
if [[ -n $FILE_PATH && $FILE_PATH == *"worker-comm"* ]]; then
  exit 0
fi

# Build reminder message based on tool type
REMINDERS=""

# Worker delegation reminder for investigation tools
case "$TOOL_NAME" in
Read | Glob | Grep | Task)
  REMINDERS="Consider delegating to Worker (codex: investigation, claude: implementation). "
  ;;
esac

# Status update reminder for significant operations (not simple reads)
case "$TOOL_NAME" in
Read | Glob | Grep)
  # Skip status reminder for simple read operations
  ;;
*)
  REMINDERS="${REMINDERS}Update .i9wa4/status-pane if task status changed."
  ;;
esac

# Output if there are any reminders
if [[ -n $REMINDERS ]]; then
  cat <<JSONEOF
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "REMINDER: ${REMINDERS}"
  }
}
JSONEOF
fi

exit 0
