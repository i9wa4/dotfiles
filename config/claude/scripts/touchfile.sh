#!/bin/bash
# touchfile.sh - Create file with standardized naming
#
# Usage:
#   touchfile.sh PATH [--role ROLE] [--source SOURCE]
#
# Arguments:
#   PATH       Output path (required)
#              - With extension (.md, .txt, etc.) → Fixed name mode
#              - Without extension → Directory mode (auto-generate filename)
#
# Options:
#   --role ROLE      Role/purpose (optional, default: memo)
#                    Examples: plan, review, debug, arch, research, memo, output
#   --source SOURCE  Source identifier (optional, default: cc)
#                    cc = Claude Code, cx = Codex CLI
#
# Output format (directory mode):
#   {DIR}/{YYYYMMDD-HHMMSS}-{SOURCE}-{ROLE}-{ID}.md
#
# Examples:
#   touchfile.sh .i9wa4/plans --role plan
#   # → .i9wa4/plans/20260122-104644-cc-plan-a1b2.md
#
#   touchfile.sh .i9wa4/tmp --role output
#   # → .i9wa4/tmp/20260122-104644-cc-output-a1b2.md
#
#   touchfile.sh .i9wa4/roadmap.md
#   # → .i9wa4/roadmap.md (fixed name, directory created)

set -euo pipefail

# Defaults
ROLE="memo"
SOURCE="cc"
TARGET_PATH=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
  --role)
    ROLE="$2"
    shift 2
    ;;
  --source)
    SOURCE="$2"
    shift 2
    ;;
  -*)
    echo "Unknown option: $1" >&2
    exit 1
    ;;
  *)
    if [[ -z "$TARGET_PATH" ]]; then
      TARGET_PATH="$1"
    else
      echo "Error: Multiple paths specified" >&2
      exit 1
    fi
    shift
    ;;
  esac
done

# Validate PATH
if [[ -z "$TARGET_PATH" ]]; then
  echo "Error: PATH is required" >&2
  echo "Usage: touchfile.sh PATH [--role ROLE] [--source SOURCE]" >&2
  exit 1
fi

# Check if PATH has an extension (fixed name mode)
if [[ "$TARGET_PATH" =~ \.[a-zA-Z0-9]+$ ]]; then
  # Fixed name mode
  FILE_PATH="$TARGET_PATH"
  mkdir -p "$(dirname "$FILE_PATH")"
else
  # Directory mode - generate timestamped filename
  TS=$(date +%Y%m%d-%H%M%S)
  ID=$(openssl rand -hex 2)
  FILE_NAME="${TS}-${SOURCE}-${ROLE}-${ID}.md"
  FILE_PATH="${TARGET_PATH}/${FILE_NAME}"
  mkdir -p "$TARGET_PATH"
fi

# Create file
touch "$FILE_PATH"

# Output the created file path
echo "$FILE_PATH"
