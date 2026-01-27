#!/usr/bin/env bash
# unified-deny.sh - Combined role-based and pattern-based deny
#
# This script combines:
# - Role-based blocking (A2A_PEER READONLY mode for non-workers)
# - Pattern-based blocking (settings.json deny patterns)
#
# Environment variables (from Claude Code PreToolUse hook):
#   TOOL_NAME  - Tool name (Bash, Read, Write, Edit, NotebookEdit)
#   TOOL_INPUT - JSON input parameters
#
# Exit codes:
#   0 - Allow
#   2 - Block

set -euo pipefail

TOOL="${TOOL_NAME:-}"
INPUT="${TOOL_INPUT:-}"

# Extract file_path from tool input
get_file_path() {
  echo "$INPUT" | jq -r '.file_path // empty' 2>/dev/null
}

# ============================================================
# 1. Role-based check (A2A_PEER mode)
# ============================================================

if [[ -n ${A2A_PEER:-} && ${A2A_PEER} != worker* ]]; then
  case "$TOOL" in
  Edit | Write | NotebookEdit)
    FILE_PATH=$(get_file_path)

    # Allow writes to .i9wa4/ directory
    if [[ -n $FILE_PATH && ($FILE_PATH == ".i9wa4/"* || $FILE_PATH == *"/.i9wa4/"*) ]]; then
      : # Allow
    # Allow writes to .postman/ directory
    elif [[ -n $FILE_PATH && ($FILE_PATH == ".postman/"* || $FILE_PATH == *"/.postman/"*) ]]; then
      : # Allow
    # Allow writes to /tmp/ directory
    elif [[ -n $FILE_PATH && $FILE_PATH == "/tmp/"* ]]; then
      : # Allow
    else
      echo "🚫 BLOCKED: ${A2A_PEER} is READONLY. Only worker* can edit files."
      echo "💡 Alternative: Send task to worker via postman"
      exit 2
    fi
    ;;
  esac
fi

# ============================================================
# 2. Pattern-based check (settings.json deny patterns)
# ============================================================

SETTINGS_FILE="${CLAUDE_CONFIG_DIR}/settings.json"

if [[ ! -f $SETTINGS_FILE ]]; then
  exit 0
fi

DENY_PATTERNS=$(jq -r '.permissions.deny[]? // empty' "$SETTINGS_FILE" 2>/dev/null)

if [[ -z $DENY_PATTERNS ]]; then
  exit 0
fi

if [[ -z $TOOL ]]; then
  exit 0
fi

# Extract relevant value based on tool type
get_tool_value() {
  case "$TOOL" in
  Bash)
    echo "$INPUT" | jq -r '.command // empty' 2>/dev/null
    ;;
  Read | Write | Edit | NotebookEdit)
    echo "$INPUT" | jq -r '.file_path // empty' 2>/dev/null
    ;;
  *)
    echo ""
    ;;
  esac
}

# Convert glob pattern to regex
glob_to_regex() {
  local pattern="$1"
  # Escape regex special characters (complex escaping requires sed)
  # shellcheck disable=SC2001
  pattern=$(echo "$pattern" | sed 's/[.^$+{}|()\\]/\\&/g')
  # Use parameter expansion for simple replacements
  pattern="${pattern//\*\*/__DOUBLESTAR__}"
  pattern="${pattern//\*/.*}"
  pattern="${pattern//__DOUBLESTAR__/.*}"
  echo "^${pattern}$"
}

# Get alternative suggestion based on pattern
get_suggestion() {
  local pattern="$1"
  case "$pattern" in
  *"git -C"*)
    echo "Use 'cd <dir> && git ...' instead of 'git -C'"
    ;;
  *"git push"*)
    echo "Ask user for permission to push"
    ;;
  *"git rebase"*)
    echo "Ask user for permission to rebase"
    ;;
  *"git reset"*)
    echo "Ask user for permission to reset"
    ;;
  *"rm"*)
    echo "Use 'mv <file> .i9wa4/tmp/' to archive instead"
    ;;
  *"sudo"*)
    echo "Ask user to run command manually with sudo"
    ;;
  *"key"* | *"token"* | *".env"* | *".ssh"* | *"secrets"*)
    echo "Sensitive file - ask user for explicit permission"
    ;;
  *)
    echo "Check CLAUDE.md for alternatives"
    ;;
  esac
}

VALUE=$(get_tool_value)

if [[ -z $VALUE ]]; then
  exit 0
fi

while IFS= read -r pattern; do
  [[ -z $pattern ]] && continue

  if [[ $pattern =~ ^([A-Za-z]+)\((.+)\)$ ]]; then
    PATTERN_TOOL="${BASH_REMATCH[1]}"
    PATTERN_GLOB="${BASH_REMATCH[2]}"

    if [[ $TOOL != "$PATTERN_TOOL" ]]; then
      continue
    fi

    # Handle colon-separated patterns (e.g., "git -C:*" means starts with)
    if [[ $PATTERN_GLOB == *":"* ]]; then
      PREFIX="${PATTERN_GLOB%%:*}"
      SUFFIX="${PATTERN_GLOB#*:}"
      # shellcheck disable=SC2001
      REGEX="^$(echo "$PREFIX" | sed 's/[.^$+{}|()\\*?]/\\&/g')"
      if [[ $SUFFIX == "*" ]]; then
        REGEX="${REGEX}.*"
      fi
    else
      REGEX=$(glob_to_regex "$PATTERN_GLOB")
    fi

    if echo "$VALUE" | grep -qE "$REGEX"; then
      SUGGESTION=$(get_suggestion "$pattern")
      echo "🚫 BLOCKED: $pattern"
      echo "💡 Alternative: $SUGGESTION"
      exit 2
    fi
  fi
done <<<"$DENY_PATTERNS"

exit 0
