#!/usr/bin/env bash
# pre-compact-save.sh - PreCompact context save
#
# Saves context snapshot before auto-compact triggers.
# Preserves git status and working state for post-compact resumption.

set -euo pipefail

# Create output file
FILE=$("${CLAUDE_CONFIG_DIR}/scripts/touchfile.sh" .i9wa4/tmp --type compact-save)

{
  echo "# Pre-Compact Context Save"
  echo ""
  echo "Timestamp: $(date +%Y-%m-%dT%H:%M:%S%z)"
  echo ""
  echo "## Git Status"
  echo ""
  echo '```'
  git status --short 2>/dev/null || echo "(not a git repo)"
  echo '```'
  echo ""
  echo "## Recent Commits"
  echo ""
  echo '```'
  git log --oneline -5 2>/dev/null || echo "(no commits)"
  echo '```'
  echo ""
  echo "## Current Branch"
  echo ""
  echo '```'
  git branch --show-current 2>/dev/null || echo "(detached HEAD or not git)"
  echo '```'
} >"$FILE"

echo "Context saved to $FILE" >&2

exit 0
