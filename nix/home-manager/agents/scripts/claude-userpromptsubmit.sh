#!/usr/bin/env bash
# claude-userpromptsubmit.sh - Inject session context into each prompt
#
# Outputs current time, tmux pane role, and the command that launched
# this session (claude or codex) as JSON additionalContext.
#
# Hook: UserPromptSubmit
set -o errexit
set -o nounset
set -o pipefail
set -o posix

CURRENT_TIME=$(date +%Y-%m-%dT%H:%M:%S%z)
ROLE=$(tmux display-message -p '#{pane_title}' 2>/dev/null || echo unknown)

# Detect launch command on this tmux pane's TTY
LAUNCH_CMD=""
PANE_TTY=$(tmux display-message -p '#{pane_tty}' 2>/dev/null | sed 's#^/dev/##') || true
if [[ -n ${PANE_TTY:-} ]]; then
  LAUNCH_PID=$(pgrep -f -t "$PANE_TTY" '^(claude|codex) ' 2>/dev/null | head -1) || true
  if [[ -n ${LAUNCH_PID:-} ]]; then
    LAUNCH_CMD=$(ps -o command= -p "$LAUNCH_PID" 2>/dev/null) || true
  fi
fi

jq -n --arg ctx "Current time: $CURRENT_TIME | Your role: $ROLE | You were launched with: ${LAUNCH_CMD:-unknown}" \
  '{"additionalContext": $ctx}'
