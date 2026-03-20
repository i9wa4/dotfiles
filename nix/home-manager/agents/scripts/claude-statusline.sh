#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
set -o posix

input=$(cat)

CTX=$(echo "$input" | jq -r '.context_window.used_percentage // 0 | floor')
MODEL=$(echo "$input" | jq -r '.model.display_name // .model.id // "?"')
VERSION=$(echo "$input" | jq -r '.version // "?"')
RATE_5H_PCT=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // 0 | floor')
RATE_5H_AT=$(date -d "@$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at')" +%H:%M)
RATE_7D_PCT=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // 0 | floor')
RATE_7D_AT=$(date -d "@$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at')" +%m-%dT%H:%M)

echo "ctx: ${CTX}% used | ${MODEL} | v${VERSION} | 5h: ${RATE_5H_PCT}% used @${RATE_5H_AT} | 7d: ${RATE_7D_PCT}% used @${RATE_7D_AT}"
