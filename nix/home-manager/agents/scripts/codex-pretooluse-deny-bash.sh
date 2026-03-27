#!/usr/bin/env bash
# codex-pretooluse-deny-bash.sh - Bash command deny hook for Codex CLI
#
# Hook: PreToolUse | Matcher: Bash
# Patterns: deny-bash-patterns.sh (generated from denied-bash-commands.nix)
set -o errexit
set -o nounset
set -o pipefail
set -o posix

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
PATTERNS_FILE="$SCRIPT_DIR/deny-bash-patterns.sh"
INPUT_JSON=$(cat)

if [ ! -f "$PATTERNS_FILE" ]; then
  exit 0
fi

# shellcheck source=/dev/null
source "$PATTERNS_FILE"

COMMAND=$(printf '%s' "$INPUT_JSON" | jq -r '.tool_input.command // empty' 2>/dev/null) || true
if [ -z "$COMMAND" ]; then
  exit 0
fi

while IFS=$';&|' read -ra line_fragments; do
  for fragment in "${line_fragments[@]}"; do
    fragment="${fragment#"${fragment%%[![:space:]]*}"}"
    fragment="${fragment%"${fragment##*[![:space:]]}"}"
    if [ -z "$fragment" ]; then
      continue
    fi

    for i in "${!DENY_PATTERNS[@]}"; do
      if [[ $fragment =~ ${DENY_PATTERNS[$i]} ]]; then
        jq -n \
          --arg reason "Command denied: ${DENY_JUSTIFICATIONS[$i]}"$'\n'"Fragment: $fragment" \
          '{
            hookSpecificOutput: {
              hookEventName: "PreToolUse",
              permissionDecision: "deny",
              permissionDecisionReason: $reason
            }
          }'
        exit 0
      fi
    done
  done
done <<<"$COMMAND"

exit 0
