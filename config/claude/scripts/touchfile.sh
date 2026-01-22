#!/bin/bash
# touchfile.sh - Create file with standardized naming
#
# Usage:
#   touchfile.sh PATH [--type TYPE]
#
# Arguments:
#   PATH       Output path (required)
#              - With extension (.md, .txt, etc.) → Fixed name mode
#              - Without extension → Directory mode (auto-generate filename)
#
# Options:
#   --type TYPE  File type (optional, default: memo)
#                Examples: plan, output, memo, review-cc, review-cx
#
# Output format (directory mode):
#   {DIR}/{YYYYMMDD-HHMMSS}-{TYPE}-{ID}.md
#
# Examples:
#   touchfile.sh .i9wa4/plans --type plan
#   # → .i9wa4/plans/20260122-104644-plan-a1b2.md
#
#   touchfile.sh .i9wa4/tmp --type output
#   # → .i9wa4/tmp/20260122-104644-output-a1b2.md
#
#   touchfile.sh .i9wa4/roadmap.md
#   # → .i9wa4/roadmap.md (fixed name, directory created)

set -euo pipefail

# Defaults
TYPE="memo"
TARGET_PATH=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
  --type)
    TYPE="$2"
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
  echo "Usage: touchfile.sh PATH [--type TYPE]" >&2
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
  FILE_NAME="${TS}-${TYPE}-${ID}.md"
  FILE_PATH="${TARGET_PATH}/${FILE_NAME}"
  mkdir -p "$TARGET_PATH"
fi

# Create file
touch "$FILE_PATH"

# Output the created file path
echo "$FILE_PATH"
echo "Created: $FILE_PATH" >&2
