#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
set -o posix

# claude-pretooluse-deny-bash.sh - Bash command deny hook
# Hook: PreToolUse | Matcher: Bash
# Patterns: deny-bash-patterns.sh (generated from denied-bash-commands.nix)

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

emit_bash_deny_payload() {
  local fragment="$1"
  local reason="$2"

  jq -n \
    --arg reason "Command denied: ${reason}"$'\n'"Fragment: $fragment" \
    '{ hookSpecificOutput: { hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $reason } }'
}

check_bash_fragment_for_denials() {
  local fragment="$1"
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

  for i in "${!DENY_PATTERNS[@]}"; do
    if [[ $fragment =~ ${DENY_PATTERNS[$i]} ]]; then
      emit_bash_deny_payload "$fragment" "${DENY_JUSTIFICATIONS[$i]}"
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
