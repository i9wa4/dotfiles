#!/usr/bin/env bash
# claude-userpromptsubmit.sh - Inject session context into each prompt
#
# Outputs current time, tmux pane role, working directory, git/usage
# context, and the command that launched this session as plain text
# additionalContext.
#
# Hook: UserPromptSubmit
set -o errexit
set -o nounset
set -o pipefail
set -o posix

# Consume stdin (Claude Code sends prompt JSON)
cat >/dev/null

extract_add_dir() {
  local launch_cmd=$1

  if [[ $launch_cmd =~ --add-dir[[:space:]]+\"([^\"]+)\" ]]; then
    printf '%s' "${BASH_REMATCH[1]}"
    return 0
  fi

  if [[ $launch_cmd =~ --add-dir[[:space:]]+([^[:space:]]+) ]]; then
    printf '%s' "${BASH_REMATCH[1]}"
  fi
}

read_add_dir_summary() {
  local add_dir=$1
  local readme_path=$add_dir/README.md

  [[ -f $readme_path ]] || return 0

  awk '
    function trim(s) {
      sub(/^[[:space:]]+/, "", s)
      sub(/[[:space:]]+$/, "", s)
      return s
    }

    function flush_paragraph(    p) {
      p = trim(paragraph)
      paragraph = ""

      if (p == "") {
        return
      }

      if (p ~ /^#/) {
        return
      }

      if (p ~ /^!\[/ || p ~ /^\[!\[/) {
        return
      }

      print p
      exit
    }

    /^[[:space:]]*$/ {
      flush_paragraph()
      next
    }

    {
      if (paragraph == "") {
        paragraph = $0
      } else {
        paragraph = paragraph " " $0
      }
    }

    END {
      flush_paragraph()
    }
  ' "$readme_path"
}

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
  LAUNCH_PID=$(pgrep -f -t "$PANE_TTY" '(^|/)(claude|codex)( |$)' 2>/dev/null | head -1) || true
  if [[ -n ${LAUNCH_PID:-} ]]; then
    LAUNCH_CMD=$(ps -o command= -p "$LAUNCH_PID" 2>/dev/null) || true
  fi
fi

# Git context via repo-status (branch, hash, staged/unstaged/unpushed counts)
GIT_INFO=$(repo-status 2>/dev/null | tr -s ' ') || true
ADD_DIR=$(extract_add_dir "${LAUNCH_CMD:-}") || true
ADD_DIR_SUMMARY=$(read_add_dir_summary "${ADD_DIR:-}") || true

# Read usage snapshot persisted by claude-statusline.sh
USAGE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/claude/usage.txt"
USAGE_INFO=$(cat "$USAGE_FILE" 2>/dev/null) || true

echo "Current time: $CURRENT_TIME | Your role: $ROLE | CWD: $CWD_DISPLAY | Git: ${GIT_INFO:-n/a} | Usage: ${USAGE_INFO:-n/a} | You were launched with: ${LAUNCH_CMD:-unknown} | add-dir context: ${ADD_DIR_SUMMARY:-n/a}"
