#!/usr/bin/env bash
# codex-userpromptsubmit.sh - Inject session context into each prompt
#
# Outputs current time, tmux pane role, working directory, git context, and
# the command that launched this session as plain text.
#
# Hook: UserPromptSubmit
set -o errexit
set -o nounset
set -o pipefail
set -o posix

# Consume stdin (prompt JSON)
cat >/dev/null

CURRENT_TIME=$(date +%Y-%m-%dT%H:%M:%S%z)
ROLE=$(tmux display-message -t "${TMUX_PANE:-}" -p '#{pane_title}' 2>/dev/null || echo unknown)
CWD_DISPLAY=$PWD
case "$CWD_DISPLAY" in
"$HOME")
  CWD_DISPLAY="~"
  ;;
"$HOME"/*)
  CWD_SUFFIX=${CWD_DISPLAY#"$HOME"/}
  CWD_DISPLAY="~"
  CWD_DISPLAY="${CWD_DISPLAY}/${CWD_SUFFIX}"
  ;;
esac

# Detect launch command on this tmux pane's TTY
LAUNCH_CMD=""
PANE_TTY=$(tmux display-message -t "${TMUX_PANE:-}" -p '#{pane_tty}' 2>/dev/null | sed 's#^/dev/##') || true
if [[ -n ${PANE_TTY:-} ]]; then
  LAUNCH_PID=$(pgrep -f -t "$PANE_TTY" '^(claude|codex) ' 2>/dev/null | head -1) || true
  if [[ -n ${LAUNCH_PID:-} ]]; then
    LAUNCH_CMD=$(ps -o command= -p "$LAUNCH_PID" 2>/dev/null) || true
  fi
fi

GIT_INFO=$(repo-status 2>/dev/null | tr -s ' ') || true

printf 'Current time: %s | Your role: %s | CWD: %s | Git: %s | You were launched with: %s' \
  "$CURRENT_TIME" "$ROLE" "$CWD_DISPLAY" "${GIT_INFO:-n/a}" "${LAUNCH_CMD:-unknown}"
