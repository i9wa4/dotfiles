#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
set -o posix

# pretooluse-deny-bash.sh - Bash command deny hook (shared by Claude/Codex)
# Hook: PreToolUse | Matcher: Bash
# Patterns: deny-bash-patterns.sh (generated from denied-bash-commands.nix)
# Same JSON-in / JSON-out schema (`hookSpecificOutput.permissionDecision`)
# is accepted by both Claude Code and Codex CLI hook runtimes.

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
PATTERNS_FILE="$SCRIPT_DIR/deny-bash-patterns.sh"
[[ ! -f $PATTERNS_FILE ]] && exit 0

# shellcheck source=/dev/null
source "$PATTERNS_FILE"

COMMAND=$(jq -r '.tool_input.command // empty' 2>/dev/null) || true
[[ -z $COMMAND ]] && exit 0

trim_bash_fragment() {
  local fragment="$1"
  fragment="${fragment#"${fragment%%[![:space:]]*}"}"
  fragment="${fragment%"${fragment##*[![:space:]]}"}"
  printf '%s' "$fragment"
}

strip_one_quote_layer() {
  local value="$1"
  local first_char
  local last_char

  if [ "${#value}" -lt 2 ]; then
    printf '%s' "$value"
    return 0
  fi

  first_char="${value:0:1}"
  last_char="${value: -1}"

  if [[ $first_char == "'" && $last_char == "'" ]] || [[ $first_char == '"' && $last_char == '"' ]]; then
    printf '%s' "${value:1:${#value}-2}"
    return 0
  fi

  printf '%s' "$value"
}

parse_heredoc_delimiter_word() {
  local line="$1"
  local word_index="$2"
  local word_len=${#line}
  local word_char
  local quote_char

  HEREDOC_DELIMITER=""
  HEREDOC_QUOTED=0
  HEREDOC_NEXT_INDEX="$word_index"

  while [ "$word_index" -lt "$word_len" ]; do
    word_char="${line:word_index:1}"
    case "$word_char" in
    [[:space:]] | ";" | "&" | "|" | "<" | ">")
      break
      ;;
    "'")
      HEREDOC_QUOTED=1
      word_index=$((word_index + 1))
      while [ "$word_index" -lt "$word_len" ] && [ "${line:word_index:1}" != "'" ]; do
        HEREDOC_DELIMITER+="${line:word_index:1}"
        word_index=$((word_index + 1))
      done
      if [ "$word_index" -ge "$word_len" ]; then
        return 1
      fi
      word_index=$((word_index + 1))
      ;;
    '"')
      quote_char='"'
      HEREDOC_QUOTED=1
      word_index=$((word_index + 1))
      while [ "$word_index" -lt "$word_len" ] && [ "${line:word_index:1}" != "$quote_char" ]; do
        word_char="${line:word_index:1}"
        if [[ $word_char == \\ ]]; then
          word_index=$((word_index + 1))
          if [ "$word_index" -ge "$word_len" ]; then
            return 1
          fi
        fi
        HEREDOC_DELIMITER+="${line:word_index:1}"
        word_index=$((word_index + 1))
      done
      if [ "$word_index" -ge "$word_len" ]; then
        return 1
      fi
      word_index=$((word_index + 1))
      ;;
    \\)
      HEREDOC_QUOTED=1
      word_index=$((word_index + 1))
      if [ "$word_index" -ge "$word_len" ]; then
        return 1
      fi
      HEREDOC_DELIMITER+="${line:word_index:1}"
      word_index=$((word_index + 1))
      ;;
    *)
      HEREDOC_DELIMITER+="$word_char"
      word_index=$((word_index + 1))
      ;;
    esac
  done

  if [ -z "$HEREDOC_DELIMITER" ] || [ "$HEREDOC_QUOTED" -ne 1 ]; then
    return 1
  fi

  if [[ $HEREDOC_DELIMITER =~ [[:space:]] ]]; then
    return 1
  fi

  HEREDOC_NEXT_INDEX="$word_index"
  return 0
}

extract_safe_data_heredoc_marker() {
  local line="$1"
  local trimmed
  local scan_index=0
  local line_len=${#line}
  local scan_char
  local previous_char
  local heredoc_count=0
  local strip_tabs=0

  trimmed="$(trim_bash_fragment "$line")"
  if [[ ! $trimmed =~ ^cat([[:space:]<>]|$) ]]; then
    return 1
  fi

  while [ "$scan_index" -lt "$line_len" ]; do
    scan_char="${line:scan_index:1}"
    previous_char=""
    if [ "$scan_index" -gt 0 ]; then
      previous_char="${line:scan_index-1:1}"
    fi

    case "$scan_char" in
    "'")
      scan_index=$((scan_index + 1))
      while [ "$scan_index" -lt "$line_len" ] && [ "${line:scan_index:1}" != "'" ]; do
        scan_index=$((scan_index + 1))
      done
      if [ "$scan_index" -ge "$line_len" ]; then
        return 1
      fi
      scan_index=$((scan_index + 1))
      continue
      ;;
    '"')
      scan_index=$((scan_index + 1))
      while [ "$scan_index" -lt "$line_len" ] && [ "${line:scan_index:1}" != '"' ]; do
        if [[ ${line:scan_index:1} == \\ ]]; then
          scan_index=$((scan_index + 1))
        fi
        scan_index=$((scan_index + 1))
      done
      if [ "$scan_index" -ge "$line_len" ]; then
        return 1
      fi
      scan_index=$((scan_index + 1))
      continue
      ;;
    \\)
      scan_index=$((scan_index + 2))
      continue
      ;;
    "#")
      if [ "$scan_index" -eq 0 ] || [[ $previous_char =~ [[:space:]] ]]; then
        break
      fi
      ;;
    ";" | "&" | "|")
      return 1
      ;;
    '`')
      return 1
      ;;
    '$')
      if [ "${line:scan_index+1:1}" = "(" ]; then
        return 1
      fi
      ;;
    "<" | ">")
      if [ "${line:scan_index+1:1}" = "(" ]; then
        return 1
      fi
      ;;
    esac

    if [ "$scan_char" = "<" ] && [ "${line:scan_index+1:1}" = "<" ]; then
      heredoc_count=$((heredoc_count + 1))
      if [ "$heredoc_count" -gt 1 ]; then
        return 1
      fi

      scan_index=$((scan_index + 2))
      strip_tabs=0
      if [ "${line:scan_index:1}" = "-" ]; then
        strip_tabs=1
        scan_index=$((scan_index + 1))
      fi
      while [ "$scan_index" -lt "$line_len" ] && [[ ${line:scan_index:1} =~ [[:space:]] ]]; do
        scan_index=$((scan_index + 1))
      done
      if ! parse_heredoc_delimiter_word "$line" "$scan_index"; then
        return 1
      fi
      scan_index="$HEREDOC_NEXT_INDEX"
      continue
    fi

    scan_index=$((scan_index + 1))
  done

  if [ "$heredoc_count" -ne 1 ]; then
    return 1
  fi

  printf '%s\t%s' "$HEREDOC_DELIMITER" "$strip_tabs"
}

# Only quoted here-doc bodies for simple data-carrier commands are inert enough
# to skip. Unsupported grammar stays in the text and is scanned fail-closed.
strip_safe_heredoc_bodies() {
  local command_text="$1"
  local -a lines=()
  local line
  local index=0
  local stripped=""
  local marker
  local delimiter
  local strip_tabs
  local body_index
  local terminator_index
  local candidate

  mapfile -t lines <<<"$command_text"

  while [ "$index" -lt "${#lines[@]}" ]; do
    line="${lines[index]}"

    if marker="$(extract_safe_data_heredoc_marker "$line")"; then
      delimiter="${marker%%$'\t'*}"
      strip_tabs="${marker##*$'\t'}"
      terminator_index=-1
      body_index=$((index + 1))

      while [ "$body_index" -lt "${#lines[@]}" ]; do
        candidate="${lines[body_index]}"
        if [ "$strip_tabs" -eq 1 ]; then
          while [[ $candidate == $'\t'* ]]; do
            candidate="${candidate#$'\t'}"
          done
        fi

        if [ "$candidate" = "$delimiter" ]; then
          terminator_index="$body_index"
          break
        fi
        body_index=$((body_index + 1))
      done

      if [ "$terminator_index" -ge 0 ]; then
        stripped+="$line"$'\n'
        index=$((terminator_index + 1))
        continue
      fi
    fi

    stripped+="$line"$'\n'
    index=$((index + 1))
  done

  printf '%s' "$stripped"
}

unwrap_shell_wrapper() {
  local fragment="$1"
  local inner_script

  if [[ $fragment =~ ^(bash|sh|zsh)[[:space:]]+-(lc|cl|c)[[:space:]]+(.+)$ ]]; then
    inner_script="${BASH_REMATCH[3]}"
    inner_script="$(trim_bash_fragment "$inner_script")"
    inner_script="$(strip_one_quote_layer "$inner_script")"
    inner_script="$(trim_bash_fragment "$inner_script")"
    printf '%s' "$inner_script"
    return 0
  fi

  return 1
}

# Bypass the regex deny check entirely for fragments that start with a
# known-safe wrapper prefix (e.g. tmux-a2a-postman, which only carries data
# in --body / --to and does not execute arbitrary commands).
# Multi-token prefixes are matched flexibly: spaces in the prefix string
# are interpreted as one-or-more whitespace in the fragment.
is_allow_prefix_bypass() {
  local fragment="$1"
  local prefix
  local prefix_re
  for prefix in "${ALLOW_PREFIX_BYPASS[@]}"; do
    prefix_re="${prefix// /[[:space:]]+}"
    if [[ $fragment =~ ^${prefix_re}([[:space:]]|$) ]]; then
      return 0
    fi
  done
  return 1
}

# Replace the quoted value following each STRIP_DATA_ARGS arg with an empty
# string before the regex deny check. This neutralises false positives from
# arg values that legitimately contain words like "rm" or "sudo" without
# weakening the check on the surrounding command (e.g. --amend still trips).
# The original fragment is preserved separately so error messages report the
# command the agent actually issued, not the stripped version.
# NOTE: sed delimiter must NOT appear inside the regex. Using `|` collides
# with the `|` inside `(^|[[:space:]])` and makes sed treat the regex as
# malformed (`unknown option to 's'`), silently emptying the fragment so
# every subsequent deny pattern matches against "" -- net effect, no denies
# fire and the hook leaks stderr noise into the harness. Use `#` instead.
strip_data_arg_values() {
  local fragment="$1"
  local arg
  for arg in "${STRIP_DATA_ARGS[@]}"; do
    fragment=$(printf '%s' "$fragment" | sed -E "s#(^|[[:space:]])${arg}[[:space:]]+\"[^\"]*\"#\1${arg} \"\"#g")
    fragment=$(printf '%s' "$fragment" | sed -E "s#(^|[[:space:]])${arg}[[:space:]]+'[^']*'#\1${arg} ''#g")
  done
  printf '%s' "$fragment"
}

normalize_command_substitution_boundaries() {
  local fragment="$1"
  fragment="${fragment//\$\(/ }"
  fragment="${fragment//\`/ }"
  printf '%s' "$fragment"
}

emit_bash_deny_payload() {
  local fragment="$1"
  local reason="$2"

  jq -n \
    --arg reason "Command denied: ${reason}"$'\n'"Fragment: $fragment" \
    '{ hookSpecificOutput: { hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $reason } }'
}

check_bash_fragment_for_denials() {
  local fragment="$1"
  local original_fragment
  local inner_script
  local i

  fragment="$(trim_bash_fragment "$fragment")"
  if [ -z "$fragment" ]; then
    return 1
  fi

  if is_allow_prefix_bypass "$fragment"; then
    return 1
  fi

  if inner_script="$(unwrap_shell_wrapper "$fragment")"; then
    if check_bash_command_for_denials "$inner_script"; then
      return 0
    fi
  fi

  original_fragment="$fragment"
  fragment="$(strip_data_arg_values "$fragment")"
  fragment="$(normalize_command_substitution_boundaries "$fragment")"

  for i in "${!DENY_PATTERNS[@]}"; do
    if [[ $fragment =~ ${DENY_PATTERNS[$i]} ]]; then
      emit_bash_deny_payload "$original_fragment" "${DENY_JUSTIFICATIONS[$i]}"
      return 0
    fi
  done

  return 1
}

check_bash_command_for_denials() {
  local command_text="$1"
  local fragment
  local char
  local index
  local single_quoted=0
  local double_quoted=0
  local escaped=0

  command_text="$(trim_bash_fragment "$command_text")"
  if [ -z "$command_text" ]; then
    return 1
  fi

  command_text="$(strip_safe_heredoc_bodies "$command_text")"
  fragment=""

  # Split only on top-level shell operators so quoted wrapper scripts stay intact.
  for ((index = 0; index < ${#command_text}; index++)); do
    char="${command_text:index:1}"

    if [ "$escaped" -eq 1 ]; then
      fragment+="$char"
      escaped=0
      continue
    fi

    if [ "$single_quoted" -eq 0 ] && [[ $char == \\ ]]; then
      fragment+="$char"
      escaped=1
      continue
    fi

    if [ "$double_quoted" -eq 0 ] && [ "$char" = "'" ]; then
      if [ "$single_quoted" -eq 1 ]; then
        single_quoted=0
      else
        single_quoted=1
      fi
      fragment+="$char"
      continue
    fi

    if [ "$single_quoted" -eq 0 ] && [ "$char" = '"' ]; then
      if [ "$double_quoted" -eq 1 ]; then
        double_quoted=0
      else
        double_quoted=1
      fi
      fragment+="$char"
      continue
    fi

    if [ "$single_quoted" -eq 0 ] && [ "$double_quoted" -eq 0 ] && { [ "$char" = ";" ] || [ "$char" = "&" ] || [ "$char" = "|" ]; }; then
      if check_bash_fragment_for_denials "$fragment"; then
        return 0
      fi
      fragment=""
      continue
    fi

    fragment+="$char"
  done

  if check_bash_fragment_for_denials "$fragment"; then
    return 0
  fi

  return 1
}

if check_bash_command_for_denials "$COMMAND"; then
  exit 0
fi

exit 0
