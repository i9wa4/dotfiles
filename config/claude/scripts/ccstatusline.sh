#!/usr/bin/env bash

input=$(cat)

USED=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
MODEL=$(echo "$input" | jq -r '.model.display_name // .model.id // "?"')
VERSION=$(echo "$input" | jq -r '.version // "?"')

echo "Context: ${USED}% used | ${MODEL} | v${VERSION}"
