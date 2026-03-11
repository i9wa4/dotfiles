#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
set -o posix

input=$(cat)

USED=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
LEFT=$((70 - USED))
if [ "$LEFT" -lt 0 ]; then
  LEFT=0
fi
MODEL=$(echo "$input" | jq -r '.model.display_name // .model.id // "?"')
VERSION=$(echo "$input" | jq -r '.version // "?"')

echo "${LEFT}% left | ${MODEL} | v${VERSION}"
