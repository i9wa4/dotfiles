#!/usr/bin/env bash
# check-external-mention
# Detect external GitHub URLs that may trigger mentions.
#
# Blocked (external owner):
#   - https://github.com/<owner>/<repo>/<any-path> (owner != i9wa4)
#   - <owner>/<repo>#<number> (owner != i9wa4)
#
# Allowed:
#   - https://github.com/<owner>/<repo> (root URL only, no trailing path)
#   - URLs in backticks: `https://github.com/...`
#   - Own repository (i9wa4) URLs

set -euo pipefail

COMMIT_MSG_FILE="${1:-}"
if [[ -z "$COMMIT_MSG_FILE" ]]; then
  echo "Usage: $0 <commit-msg-file>" >&2
  exit 1
fi

OWNER="i9wa4"
EXIT_CODE=0

while IFS= read -r line; do
  # Skip lines that are entirely in backticks (code blocks)
  if [[ "$line" =~ ^\`.*\`$ ]]; then
    continue
  fi

  # Remove backtick-quoted sections from the line for checking
  # shellcheck disable=SC2001,SC2016
  cleaned_line=$(echo "$line" | sed 's/`[^`]*`//g')

  # Check for external GitHub URLs with path: https://github.com/<owner>/<repo>/<path>
  if echo "$cleaned_line" | grep -qE "https://github\.com/[^/]+/[^/]+/[^ ]*"; then
    url_owner=$(echo "$cleaned_line" | grep -oE "https://github\.com/[^/]+" | sed 's|https://github.com/||' | head -1)
    if [[ -n "$url_owner" && "$url_owner" != "$OWNER" ]]; then
      echo "ERROR: External GitHub URL with path detected (may trigger mention):" >&2
      echo "  $line" >&2
      echo "  Use backticks or repository root URL only." >&2
      EXIT_CODE=1
    fi
  fi

  # Check for shorthand references: <owner>/<repo>#<number>
  if echo "$cleaned_line" | grep -qE "[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+#[0-9]+"; then
    ref_owner=$(echo "$cleaned_line" | grep -oE "[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+#[0-9]+" | cut -d'/' -f1 | head -1)
    if [[ -n "$ref_owner" && "$ref_owner" != "$OWNER" ]]; then
      echo "ERROR: External issue/PR reference detected (may trigger mention):" >&2
      echo "  $line" >&2
      echo "  Use backticks or 'cf. <repo> issue <number>' format instead." >&2
      EXIT_CODE=1
    fi
  fi
done <"$COMMIT_MSG_FILE"

exit $EXIT_CODE
