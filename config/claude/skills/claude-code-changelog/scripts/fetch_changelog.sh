#!/usr/bin/env bash
# Fetch Claude Code CHANGELOG from GitHub
# Usage: ./fetch_changelog.sh [output_file]

set -euo pipefail

OUTPUT_FILE="${1:-/tmp/claude-code-changelog.md}"

echo "Fetching Claude Code CHANGELOG..."
gh api repos/anthropics/claude-code/contents/CHANGELOG.md --jq '.content' | base64 -d >"${OUTPUT_FILE}"

echo "Saved to: ${OUTPUT_FILE}"
echo "Latest version:"
head -10 "${OUTPUT_FILE}" | grep -E '^## [0-9]+\.[0-9]+\.[0-9]+' | head -1
