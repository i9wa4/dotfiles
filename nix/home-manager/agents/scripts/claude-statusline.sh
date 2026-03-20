#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
set -o posix

input=$(cat)

CTX=$(echo "$input" | jq -r '.context_window.used_percentage // 0 | floor')
MODEL=$(echo "$input" | jq -r '.model.display_name // .model.id // "?"')
VERSION=$(echo "$input" | jq -r '.version // "?"')
RATE_5H=$(echo "$input" | jq -r '"5h: \(.rate_limits.session.used_percentage|floor)% used @\(.rate_limits.session.resets_at[11:16])"')
RATE_7D=$(echo "$input" | jq -r '"7d: \(.rate_limits.weekly.used_percentage|floor)% used @\(.rate_limits.weekly.resets_at[5:16])"')

echo "ctx: ${CTX}% used | ${MODEL} | v${VERSION} | ${RATE_5H} | ${RATE_7D}"
