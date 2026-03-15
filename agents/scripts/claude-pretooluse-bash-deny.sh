#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
set -o posix

# claude-pretooluse-bash-deny.sh - Bash command deny hook
#
# Deny patterns and justification messages are loaded from a Nix-generated
# file (SSOT: denied-bash-commands.nix).
#
# Usage: claude-pretooluse-bash-deny.sh <patterns-file>
#
# Hook: PreToolUse
# Matcher: Bash

PATTERNS_FILE="${1:-}"
[[ -z $PATTERNS_FILE || ! -f $PATTERNS_FILE ]] && exit 0

# shellcheck source=/dev/null
source "$PATTERNS_FILE"

COMMAND=$(cat | jq -r '.tool_input.command // empty' 2>/dev/null)
[[ -z $COMMAND ]] && exit 0

IFS=$';&|' read -ra FRAGMENTS <<<"$COMMAND"

for fragment in "${FRAGMENTS[@]}"; do
  fragment="${fragment#"${fragment%%[![:space:]]*}"}"
  fragment="${fragment%"${fragment##*[![:space:]]}"}"

  for i in "${!DENY_PATTERNS[@]}"; do
    if echo "$fragment" | grep -qE "${DENY_PATTERNS[$i]}"; then
      jq -n --arg reason "Command denied: ${DENY_JUSTIFICATIONS[$i]}"$'\n'"Fragment: $fragment" \
        '{ hookSpecificOutput: { hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $reason } }'
      exit 0
    fi
  done
done

exit 0
