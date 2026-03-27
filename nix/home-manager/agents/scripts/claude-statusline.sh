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
RATE_5H_TS=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // 0 | floor')
RATE_5H_AT=$(jq -nr --argjson ts "$RATE_5H_TS" '$ts | localtime | strftime("%H:%M")')
RATE_7D_PCT=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // 0 | floor')
RATE_7D_TS=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // 0 | floor')
RATE_7D_AT=$(jq -nr --argjson ts "$RATE_7D_TS" '$ts | localtime | strftime("%m-%dT%H:%M")')

# Persist usage snapshot for UserPromptSubmit hook to inject into context
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/claude"
mkdir -p "$STATE_DIR"
# Atomic write: rename(2) is safe under concurrent readers/writers
printf '%s\n' "ctx: ${CTX}% | 5h: ${RATE_5H_PCT}% @${RATE_5H_AT} | 7d: ${RATE_7D_PCT}% @${RATE_7D_AT}" >"$STATE_DIR/usage.txt.tmp"
mv "$STATE_DIR/usage.txt.tmp" "$STATE_DIR/usage.txt"

echo "ctx: ${CTX}% used | ${MODEL} | v${VERSION} | 5h: ${RATE_5H_PCT}% used @${RATE_5H_AT} | 7d: ${RATE_7D_PCT}% used @${RATE_7D_AT}"
