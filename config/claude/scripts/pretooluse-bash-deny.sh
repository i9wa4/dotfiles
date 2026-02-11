#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
set -o posix

# pretooluse-bash-deny.sh - Bash command validator
#
# Validates Bash commands against deny patterns to prevent bypassing
# permission rules via &&, ||, ;, | operators or variable expansion.
#
# Hook: PreToolUse
# Matcher: Bash
#
# Input (stdin JSON):
#   {
#     "hook_event_name": "PreToolUse",
#     "tool_name": "Bash",
#     "tool_input": { "command": "..." }
#   }
#
# Output:
#   JSON with hookSpecificOutput containing permissionDecision and reason

# Read JSON from stdin
INPUT=$(cat)

# Extract tool_name
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)

# Only check Bash commands
[[ $TOOL != "Bash" ]] && exit 0

# Extract command
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

# Skip if no command
[[ -z $COMMAND ]] && exit 0

# Define deny patterns (from settings.json)
# NOTE: These patterns check for command presence anywhere in the string
DENY_PATTERNS=(
  'git -C'
  'git push'
  'git rebase'
  'git reset'
  '\brm\b'   # Word boundary to avoid matching "farm", "chmod", etc.
  '\bsudo\b' # Word boundary
)

# Split command by shell operators and check each fragment
# NOTE: This is a basic split - won't catch all edge cases with quotes/escapes
IFS=$';&|' read -ra FRAGMENTS <<<"$COMMAND"

for fragment in "${FRAGMENTS[@]}"; do
  # Trim leading/trailing whitespace
  fragment=$(echo "$fragment" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

  # Check against each deny pattern
  for pattern in "${DENY_PATTERNS[@]}"; do
    if echo "$fragment" | grep -qE "$pattern"; then
      REASON="🚫 Command contains prohibited pattern: $pattern"$'\n'"💡 Fragment: $fragment"$'\n'"💡 Full command: $COMMAND"
      jq -n \
        --arg reason "$REASON" \
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

exit 0
