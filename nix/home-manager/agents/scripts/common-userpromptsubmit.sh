#!/usr/bin/env bash
# common-userpromptsubmit.sh - Shared UserPromptSubmit hook entrypoint
#
# Mode-specific output:
# - codex: time, role, cwd, git, launch command, add-dir path/context
# - claude: same as codex plus usage snapshot
#
# Hook: UserPromptSubmit
set -o errexit
set -o nounset
set -o pipefail
set -o posix

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

resolve_add_dir() {
  local launch_cmd=$1
  local add_dir=""

  add_dir=$(extract_add_dir "$launch_cmd") || true
  if [[ -n $add_dir && -d $add_dir ]]; then
    printf '%s' "$add_dir"
    return 0
  fi

  if [[ -n ${SUBDIR:-} && -d ${SUBDIR:-} ]]; then
    printf '%s' "$SUBDIR"
  fi
}

render_cwd_display() {
  local cwd_display=$PWD
  local cwd_suffix=""

  case "$cwd_display" in
  "$HOME")
    cwd_display="~"
    ;;
  "$HOME"/*)
    cwd_suffix=${cwd_display#"$HOME"/}
    # shellcheck disable=SC2088
    printf -v cwd_display '~/%s' "$cwd_suffix"
    ;;
  esac

  printf '%s' "$cwd_display"
}

detect_launch_cmd() {
  local pane_tty=""
  local launch_pid=""
  local launch_cmd=""

  pane_tty=$(tmux display-message -t "${TMUX_PANE:-}" -p '#{pane_tty}' 2>/dev/null | sed 's#^/dev/##') || true
  if [[ -n ${pane_tty:-} ]]; then
    launch_pid=$(pgrep -f -t "$pane_tty" '(^|/)(claude|codex)( |$)' 2>/dev/null | head -1) || true
    if [[ -n ${launch_pid:-} ]]; then
      launch_cmd=$(ps -o command= -p "$launch_pid" 2>/dev/null) || true
    fi
  fi

  printf '%s' "$launch_cmd"
}

collect_userpromptsubmit_context() {
  CURRENT_TIME=$(date +%Y-%m-%dT%H:%M:%S%z)
  ROLE=$(tmux display-message -t "${TMUX_PANE:-}" -p '#{pane_title}' 2>/dev/null || echo unknown)
  CWD_DISPLAY=$(render_cwd_display)
  LAUNCH_CMD=$(detect_launch_cmd)
  GIT_INFO=$(repo-status 2>/dev/null | tr -s ' ') || true
  ADD_DIR=$(resolve_add_dir "${LAUNCH_CMD:-}") || true
  ADD_DIR_SUMMARY=$(read_add_dir_summary "${ADD_DIR:-}") || true
  export CURRENT_TIME ROLE CWD_DISPLAY LAUNCH_CMD GIT_INFO ADD_DIR ADD_DIR_SUMMARY
}

read_usage_info() {
  local usage_file="${XDG_STATE_HOME:-$HOME/.local/state}/claude/usage.txt"
  cat "$usage_file" 2>/dev/null || true
}

main() {
  local mode="${1:-codex}"
  local usage_info=""

  # Consume stdin (prompt JSON)
  cat >/dev/null
  collect_userpromptsubmit_context

  case "$mode" in
  codex)
    printf 'Current time: %s | Your role: %s | CWD: %s | Git: %s | You were launched with: %s | add-dir path: %s | add-dir context: %s' \
      "$CURRENT_TIME" "$ROLE" "$CWD_DISPLAY" "${GIT_INFO:-n/a}" "${LAUNCH_CMD:-unknown}" "${ADD_DIR:-n/a}" "${ADD_DIR_SUMMARY:-n/a}"
    ;;
  claude)
    usage_info=$(read_usage_info)
    printf 'Current time: %s | Your role: %s | CWD: %s | Git: %s | Usage: %s | You were launched with: %s | add-dir path: %s | add-dir context: %s' \
      "$CURRENT_TIME" "$ROLE" "$CWD_DISPLAY" "${GIT_INFO:-n/a}" "${usage_info:-n/a}" "${LAUNCH_CMD:-unknown}" "${ADD_DIR:-n/a}" "${ADD_DIR_SUMMARY:-n/a}"
    ;;
  *)
    printf 'unknown mode: %s\n' "$mode" >&2
    return 1
    ;;
  esac
}

main "$@"
