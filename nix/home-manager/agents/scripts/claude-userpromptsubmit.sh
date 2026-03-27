#!/usr/bin/env bash
# claude-userpromptsubmit.sh - Inject session context into each prompt
#
# Outputs current time, tmux pane role, working directory, and git/usage
# context as plain text additionalContext.
#
# Hook: UserPromptSubmit
set -o errexit
set -o nounset
set -o pipefail
set -o posix

# Consume stdin (Claude Code sends prompt JSON)
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

# Git context via repo-status (branch, hash, staged/unstaged/unpushed counts)
GIT_INFO=$(repo-status 2>/dev/null | tr -s ' ') || true

# Read usage snapshot persisted by claude-statusline.sh
USAGE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/claude/usage.txt"
USAGE_INFO=$(cat "$USAGE_FILE" 2>/dev/null) || true

echo "Current time: $CURRENT_TIME | Your role: $ROLE | CWD: $CWD_DISPLAY | Git: ${GIT_INFO:-n/a} | Usage: ${USAGE_INFO:-n/a}"
