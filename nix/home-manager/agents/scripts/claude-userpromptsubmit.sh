#!/usr/bin/env bash
# claude-userpromptsubmit.sh - Inject session context into each prompt
#
# Outputs current time, tmux pane role, working directory, git/usage
# context, and the command that launched this session as plain text
# additionalContext. If the launch command cannot be recovered reliably,
# falls back to the inherited SUBDIR add-dir path from the pane environment.
#
# Hook: UserPromptSubmit
set -o errexit
set -o nounset
set -o pipefail
set -o posix

SCRIPT_DIR=$(dirname -- "${BASH_SOURCE[0]}")
SCRIPT_DIR=$(cd -- "$SCRIPT_DIR" && pwd)
# shellcheck source-path=SCRIPTDIR
# shellcheck source=common-userpromptsubmit.sh
# shellcheck disable=SC1091
. "$SCRIPT_DIR/common-userpromptsubmit.sh"

# Consume stdin (Claude Code sends prompt JSON)
cat >/dev/null
collect_userpromptsubmit_context

# Read usage snapshot persisted by claude-statusline.sh
USAGE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/claude/usage.txt"
USAGE_INFO=$(cat "$USAGE_FILE" 2>/dev/null) || true

printf 'Current time: %s | Your role: %s | CWD: %s | Git: %s | Usage: %s | You were launched with: %s | add-dir path: %s | add-dir context: %s' \
  "$CURRENT_TIME" "$ROLE" "$CWD_DISPLAY" "${GIT_INFO:-n/a}" "${USAGE_INFO:-n/a}" "${LAUNCH_CMD:-unknown}" "${ADD_DIR:-n/a}" "${ADD_DIR_SUMMARY:-n/a}"
