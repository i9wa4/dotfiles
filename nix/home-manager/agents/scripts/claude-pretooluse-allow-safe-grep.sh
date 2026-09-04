#!/usr/bin/env bash
# PreToolUse hook (Bash matcher): auto-allow safe, single, read-only
# grep/rg/ripgrep commands (optionally prefixed by "cd <dir> && ") so they
# skip the interactive permission prompt. Reviewed and approved by `approver`
# across 15 adversarial test scenarios; do not weaken any check below without
# an equivalent re-review -- each one closes a specific chaining/substitution/
# redirection/background-operator/newline bypass gap.

c=$(jq -r '.tool_input.command // empty')
[ -z "$c" ] && exit 0

# shellcheck disable=SC2016 # literal substring match, not variable expansion
case "$c" in
*';'* | *'|'* | *'`'* | *'$('* | *'<('* | *'>('* | *'<'* | *'>'* | *$'\n'* | *$'\r'*)
  exit 0
  ;;
esac

tmp="${c//&&/}"
case "$tmp" in
*'&'*) exit 0 ;;
esac

amp_count=$(printf '%s' "$c" | grep -o '&&' | wc -l | tr -d ' ')
rest="$c"
if [ "$amp_count" = "1" ]; then
  case "$c" in
  cd\ *' && '*) rest="${c#*' && '}" ;;
  *) exit 0 ;;
  esac
elif [ "$amp_count" != "0" ]; then
  exit 0
fi

case "$rest" in
grep\ * | grep | rg\ * | rg | ripgrep\ * | ripgrep) : ;;
*) exit 0 ;;
esac

lc=$(printf '%s' "$c" | tr '[:upper:]' '[:lower:]')
case "$lc" in
*key* | *token* | *secret* | *.env* | *.ssh* | *credential* | *password*) exit 0 ;;
esac

case "$rest" in
*'rm '* | *'sudo '* | *'curl '* | *'wget '*) exit 0 ;;
esac

echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow","permissionDecisionReason":"Auto-allowed: single read-only grep/rg command, no chaining/substitution/redirection, no sensitive-path or risky-construct indicators."}}'
exit 0
