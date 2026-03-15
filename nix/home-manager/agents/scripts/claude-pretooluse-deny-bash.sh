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

while IFS=$';&|' read -ra line_fragments; do
  for fragment in "${line_fragments[@]}"; do
    fragment="${fragment#"${fragment%%[![:space:]]*}"}"
    fragment="${fragment%"${fragment##*[![:space:]]}"}"
    [[ -z $fragment ]] && continue
    for i in "${!DENY_PATTERNS[@]}"; do
      if [[ $fragment =~ ${DENY_PATTERNS[$i]} ]]; then
        jq -n --arg reason "Command denied: ${DENY_JUSTIFICATIONS[$i]}"$'\n'"Fragment: $fragment" \
          '{ hookSpecificOutput: { hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $reason } }'
        exit 0
      fi
    done
  done
done <<<"$COMMAND"

exit 0
