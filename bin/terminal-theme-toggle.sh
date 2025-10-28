#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
set -o posix

CACHE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/terminal-theme"

# 現在のテーマを取得
if [ -f "$CACHE_FILE" ]; then
  current=$(cat "$CACHE_FILE" | tr -d ' \n')
else
  current="dark"
fi

# トグル
if [ "$current" = "dark" ]; then
  echo "light" > "$CACHE_FILE"
else
  echo "dark" > "$CACHE_FILE"
fi
