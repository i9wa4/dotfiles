#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
set -o posix

# post-write-check.sh - PostToolUse lint/format check
#
# Runs lightweight syntax checks after Write/Edit/NotebookEdit.
# Always exits 0 (advisory only, never blocks).
#
# Input (stdin JSON from Claude Code PostToolUse hook):
#   { "tool_name": "...", "tool_input": { "file_path": "..." }, ... }

INPUT=$(cat)

# jq required for JSON parsing
if ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)

# Skip if no file path
[[ -z $FILE_PATH ]] && exit 0

# Skip if file doesn't exist
[[ ! -f $FILE_PATH ]] && exit 0

EXT="${FILE_PATH##*.}"

case ".$EXT" in
  .sh | .bash)
    if command -v shellcheck >/dev/null 2>&1; then
      shellcheck --severity=warning "$FILE_PATH" >&2 || true
    fi
    ;;
  .json)
    if command -v jq >/dev/null 2>&1; then
      if ! jq . "$FILE_PATH" >/dev/null 2>&1; then
        echo "WARNING: JSON syntax error in $FILE_PATH" >&2
      fi
    fi
    ;;
  .yaml | .yml)
    if command -v python3 >/dev/null 2>&1; then
      if python3 -c "import yaml" 2>/dev/null; then
        if ! python3 -c "import sys, yaml; yaml.safe_load(open(sys.argv[1]))" "$FILE_PATH" 2>/dev/null; then
          echo "WARNING: YAML syntax error in $FILE_PATH" >&2
        fi
      fi
    fi
    ;;
  .md)
    # Check trailing newline
    if [[ -s $FILE_PATH ]] && [[ $(tail -c 1 "$FILE_PATH" | wc -l) -eq 0 ]]; then
      echo "NOTE: $FILE_PATH does not end with newline" >&2
    fi
    ;;
esac

exit 0
