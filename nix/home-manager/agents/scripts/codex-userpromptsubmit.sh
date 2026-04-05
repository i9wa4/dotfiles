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

SCRIPT_DIR=$(dirname -- "${BASH_SOURCE[0]}")
SCRIPT_DIR=$(cd -- "$SCRIPT_DIR" && pwd)
# shellcheck source-path=SCRIPTDIR
# shellcheck source=common-userpromptsubmit.sh
# shellcheck disable=SC1091
. "$SCRIPT_DIR/common-userpromptsubmit.sh"

# Consume stdin (prompt JSON)
cat >/dev/null
collect_userpromptsubmit_context

printf 'Current time: %s | Your role: %s | CWD: %s | Git: %s | You were launched with: %s | add-dir path: %s | add-dir context: %s' \
  "$CURRENT_TIME" "$ROLE" "$CWD_DISPLAY" "${GIT_INFO:-n/a}" "${LAUNCH_CMD:-unknown}" "${ADD_DIR:-n/a}" "${ADD_DIR_SUMMARY:-n/a}"
