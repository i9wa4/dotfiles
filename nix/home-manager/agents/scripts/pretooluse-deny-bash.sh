#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
set -o posix

# pretooluse-deny-bash.sh - Bash command default-deny/allowlist hook
# (shared by Claude/Codex)
# Hook: PreToolUse | Matcher: Bash
# Patterns: deny-bash-patterns.sh (generated from denied-bash-commands.nix
# and allowed-bash-commands.nix; despite the filename, this now carries
# both ALLOW_PATTERNS and DENY_PATTERNS -- renaming it is a separate,
# larger diff across both Nix modules and is left for a follow-up).
# Same JSON-in / JSON-out schema (`hookSpecificOutput.permissionDecision`)
# is accepted by both Claude Code and Codex CLI hook runtimes.
#
# ── Model ──────────────────────────────────────────────────────────────
#
# Default-deny: every command is denied unless it matches an allow path.
# Every decision is explicit -- this script never silently exits 0 with
# no JSON output the way its default-allow predecessor did, because
# under default-deny a silent "no opinion" would mean "nothing works."
#
# Allow paths, checked in this order:
#   1. check_grep_rg_allow: a dedicated, already approver-reviewed
#      (twice) procedural rule for single-shape grep/rg/ripgrep
#      invocations, absorbed here from the former standalone
#      claude-pretooluse-allow-safe-grep.sh design (issue #342) rather
#      than kept as a second, separately-maintained hook. Operates on
#      the whole raw command, exactly as it did as a standalone hook --
#      it already rejects any chaining/substitution/redirection
#      metacharacter outright, so it does not participate in the
#      per-fragment split below.
#   2. ALLOW_PATTERNS (allowed-bash-commands.nix): per-fragment regex
#      allowlist for simple, side-effect-free commands (ls, pwd, git
#      status, the tmux-a2a-postman entry that supersedes the old
#      ALLOW_PREFIX_BYPASS mechanism, etc.).
#
# denied-bash-commands.nix's DENY_PATTERNS are NOT a second enforcement
# gate. They no longer decide whether a command runs -- everything that
# misses the allow paths above is denied regardless of whether it also
# matches a DENY_PATTERNS entry. What DENY_PATTERNS still controls is
# message quality: a command that is both off the allowlist and matches
# a known-bad pattern here gets that pattern's specific, repair-oriented
# justification; anything else off the allowlist gets a generic
# not-on-the-allowlist message. Same outcome (denied) either way.
#
# Every deny message also appends a hint to request the command through
# `tmux-a2a-postman execute-bash` instead of retrying it directly.

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
PATTERNS_FILE="$SCRIPT_DIR/deny-bash-patterns.sh"
[[ ! -f $PATTERNS_FILE ]] && exit 0

# shellcheck source=/dev/null
source "$PATTERNS_FILE"

COMMAND=$(jq -r '.tool_input.command // empty' 2>/dev/null) || true
[[ -z $COMMAND ]] && exit 0

EXECUTE_BASH_HINT="If this command should run, request it via 'tmux-a2a-postman execute-bash --label <short-label> --category <category> --reason <why>' instead of retrying it directly."

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

# Replace the quoted value following each STRIP_DATA_ARGS arg with an empty
# string before regex matching (deny OR allow). This neutralises false
# positives from arg values that legitimately contain words like "rm" or
# "sudo" without weakening the check on the surrounding command (e.g.
# --amend still trips the deny check; a stray "-m" value can't smuggle an
# allow-pattern match either). The original fragment is preserved
# separately so messages report the command the agent actually issued,
# not the stripped version.
# NOTE: sed delimiter must NOT appear inside the regex. Using `|` collides
# with the `|` inside `(^|[[:space:]])` and makes sed treat the regex as
# malformed (`unknown option to 's'`), silently emptying the fragment --
# net effect, no denies OR allows fire and the hook falls through to a
# default deny on everything. Use `#` instead.
strip_data_arg_values() {
  local fragment="$1"
  local arg
  for arg in "${STRIP_DATA_ARGS[@]}"; do
    fragment=$(printf '%s' "$fragment" | sed -E "s#(^|[[:space:]])${arg}[[:space:]]+\"[^\"]*\"#\1${arg} \"\"#g")
    fragment=$(printf '%s' "$fragment" | sed -E "s#(^|[[:space:]])${arg}[[:space:]]+'[^']*'#\1${arg} ''#g")
  done
  printf '%s' "$fragment"
}

# Reject constructs that could smuggle additional commands past a
# prefix-shaped allow match (e.g. "ls > /etc/passwd", "ls $(rm -rf /)",
# "ls `evil`"). ALLOW_PATTERNS only checks a fragment's leading token, so
# this guard must run before any allow-pattern match is trusted -- unlike
# DENY_PATTERNS, where a false negative here would just miss a specific
# friendlier message and fall through to the (still-safe) generic deny,
# a false negative on the ALLOW side would incorrectly permit execution.
# `;`, `&`, `|` are excluded from this list because the caller already
# splits on those as top-level fragment separators before this check
# runs; a literal one inside the current fragment would only be possible
# inside quotes, which is data, not a live shell operator.
#
# Quote-aware: reuses the same char-by-char quote-tracking walk_bash_fragments
# uses, rather than a naive substring case-match, so a backtick/$(/</> inside
# a quoted argument (data) is not confused with a live shell metacharacter.
# A run of two or more unquoted `<` is a heredoc (`<<`) or here-string
# (`<<<`) marker, not input redirection -- unlike a bare single `<`, it never
# reads from an arbitrary file, so it is not flagged. `>` gets no equivalent
# exemption: `>>` is still real output redirection either way.
# shellcheck disable=SC2329 # invoked indirectly via check_bash_fragment_for_allow
fragment_has_risky_construct() {
  local fragment="$1"
  local char next_char
  local index
  local single_quoted=0 double_quoted=0 escaped=0

  for ((index = 0; index < ${#fragment}; index++)); do
    char="${fragment:index:1}"

    if [ "$escaped" -eq 1 ]; then
      escaped=0
      continue
    fi

    if [ "$single_quoted" -eq 0 ] && [[ $char == \\ ]]; then
      escaped=1
      continue
    fi

    if [ "$double_quoted" -eq 0 ] && [ "$char" = "'" ]; then
      if [ "$single_quoted" -eq 1 ]; then
        single_quoted=0
      else
        single_quoted=1
      fi
      continue
    fi

    if [ "$single_quoted" -eq 0 ] && [ "$char" = '"' ]; then
      if [ "$double_quoted" -eq 1 ]; then
        double_quoted=0
      else
        double_quoted=1
      fi
      continue
    fi

    if [ "$single_quoted" -eq 1 ] || [ "$double_quoted" -eq 1 ]; then
      if [ "$char" = '`' ]; then
        # Backtick and $( ) still expand inside double quotes in real
        # bash, so unlike </>, they stay risky there too.
        if [ "$double_quoted" -eq 1 ]; then
          return 0
        fi
      elif [ "$char" = '$' ] && [ "${fragment:index+1:1}" = "(" ] && [ "$double_quoted" -eq 1 ]; then
        return 0
      fi
      continue
    fi

    case "$char" in
    '`')
      return 0
      ;;
    '$')
      if [ "${fragment:index+1:1}" = "(" ]; then
        return 0
      fi
      ;;
    '<')
      next_char="${fragment:index+1:1}"
      if [ "$next_char" = "<" ]; then
        # Heredoc (<<, <<-) or here-string (<<<) marker: skip the whole
        # run of unquoted `<` so neither end of it is mistaken for a
        # standalone input-redirection `<`.
        while [ "${fragment:index+1:1}" = "<" ]; do
          index=$((index + 1))
        done
        continue
      fi
      return 0
      ;;
    '>')
      return 0
      ;;
    esac
  done

  return 1
}

emit_deny_payload() {
  local fragment="$1"
  local reason="$2"

  jq -n \
    --arg reason "Command denied: ${reason}"$'\n'"Fragment: $fragment"$'\n'"${EXECUTE_BASH_HINT}" \
    '{ hookSpecificOutput: { hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $reason } }'
}

emit_allow_payload() {
  local reason="$1"

  jq -n \
    --arg reason "$reason" \
    '{ hookSpecificOutput: { hookEventName: "PreToolUse", permissionDecision: "allow", permissionDecisionReason: $reason } }'
}

# Ported verbatim (behavior-for-behavior) from the already approver-reviewed
# (twice) standalone grep/rg auto-allow hook (issue #342). Operates on the
# WHOLE raw command, not a split fragment, exactly as it did as a
# standalone hook: any chaining/substitution/redirection metacharacter
# anywhere in the command is an outright reject, and at most one `&&` is
# tolerated, only in the exact `cd <path> && grep/rg ...` shape.
check_grep_rg_allow() {
  local c="$1"
  local tmp
  local amp_count
  local rest
  local lc

  # shellcheck disable=SC2016 # case pattern, not variable expansion
  case "$c" in
  *';'* | *'|'* | *'`'* | *'$('* | *'<('* | *'>('* | *'<'* | *'>'* | *$'\n'* | *$'\r'*)
    return 1
    ;;
  esac

  tmp="${c//&&/}"
  case "$tmp" in
  *'&'*) return 1 ;;
  esac

  amp_count=$(printf '%s' "$c" | grep -o '&&' | wc -l | tr -d ' ')
  rest="$c"
  if [ "$amp_count" = "1" ]; then
    case "$c" in
    cd\ *' && '*) rest="${c#*' && '}" ;;
    *) return 1 ;;
    esac
  elif [ "$amp_count" != "0" ]; then
    return 1
  fi

  case "$rest" in
  grep\ * | grep | rg\ * | rg | ripgrep\ * | ripgrep) : ;;
  *) return 1 ;;
  esac

  lc=$(printf '%s' "$c" | tr '[:upper:]' '[:lower:]')
  case "$lc" in
  *key* | *token* | *secret* | *.env* | *.ssh* | *credential* | *password*)
    return 1
    ;;
  esac

  case "$rest" in
  *'rm '* | *'sudo '* | *'curl '* | *'wget '*) return 1 ;;
  esac

  return 0
}

# shellcheck disable=SC2329 # invoked indirectly via walk_bash_fragments
check_bash_fragment_for_allow() {
  local fragment="$1"
  local original_fragment
  local inner_script
  local i

  fragment="$(trim_bash_fragment "$fragment")"
  if [ -z "$fragment" ]; then
    # An empty fragment (e.g. a trailing `;`) contributes nothing to run
    # and is not itself a command to gate.
    return 0
  fi

  if inner_script="$(unwrap_shell_wrapper "$fragment")"; then
    check_bash_command_for_allow "$inner_script"
    return $?
  fi

  if fragment_has_risky_construct "$fragment"; then
    return 1
  fi

  original_fragment="$fragment"
  fragment="$(strip_data_arg_values "$fragment")"

  for i in "${!ALLOW_PATTERNS[@]}"; do
    if [[ $fragment =~ ${ALLOW_PATTERNS[$i]} ]]; then
      return 0
    fi
  done

  return 1
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

  if inner_script="$(unwrap_shell_wrapper "$fragment")"; then
    if check_bash_command_for_denials "$inner_script"; then
      return 0
    fi
  fi

  original_fragment="$fragment"
  fragment="$(strip_data_arg_values "$fragment")"

  for i in "${!DENY_PATTERNS[@]}"; do
    if [[ $fragment =~ ${DENY_PATTERNS[$i]} ]]; then
      emit_deny_payload "$original_fragment" "${DENY_JUSTIFICATIONS[$i]}"
      return 0
    fi
  done

  return 1
}

# Split command_text on top-level shell operators (;&|), respecting
# quotes, and evaluate every resulting fragment with the supplied
# per-fragment checker function name. Returns 0 only if the checker
# accepted every fragment (used for the allow pass, where all fragments
# must be individually safe); returns 1 as soon as one fragment fails.
walk_bash_fragments() {
  local command_text="$1"
  local checker="$2"
  local fragment
  local char
  local index
  local single_quoted=0
  local double_quoted=0
  local escaped=0

  command_text="$(trim_bash_fragment "$command_text")"
  if [ -z "$command_text" ]; then
    return 0
  fi

  fragment=""

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
      if ! "$checker" "$fragment"; then
        return 1
      fi
      fragment=""
      continue
    fi

    fragment+="$char"
  done

  if ! "$checker" "$fragment"; then
    return 1
  fi

  return 0
}

check_bash_command_for_allow() {
  walk_bash_fragments "$1" check_bash_fragment_for_allow
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

    if [ "$single_quoted" -eq 0 ] && [ "$char" = "'" ]; then
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

# ── Decision ───────────────────────────────────────────────────────────

if check_grep_rg_allow "$COMMAND"; then
  emit_allow_payload "Auto-allowed: single read-only grep/rg command, no chaining/substitution/redirection, no sensitive-path or risky-construct indicators."
  exit 0
fi

if check_bash_command_for_allow "$COMMAND"; then
  emit_allow_payload "Auto-allowed: every part of this command matched the read-only/side-effect-free Bash allowlist."
  exit 0
fi

if check_bash_command_for_denials "$COMMAND"; then
  exit 0
fi

jq -n \
  --arg reason "Command denied: not on the allowlist for automatic execution."$'\n'"Fragment: $COMMAND"$'\n'"${EXECUTE_BASH_HINT}" \
  '{ hookSpecificOutput: { hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $reason } }'
exit 0
