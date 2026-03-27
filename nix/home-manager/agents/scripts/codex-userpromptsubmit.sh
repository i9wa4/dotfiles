#!/usr/bin/env bash
# codex-userpromptsubmit.sh - Inject session context into each prompt
#
# Outputs current time and tmux pane role as plain text.
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

printf 'Current time: %s | Your role: %s' \
  "$CURRENT_TIME" "$ROLE"
