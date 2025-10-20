#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail
set -o posix

OPACITY_FILE="$HOME/.config/alacritty/opacity.toml"

if [[ -f $OPACITY_FILE ]]; then
  OPACITY=$(grep "^opacity" "$OPACITY_FILE" | sed 's/.*= *//')
  PERCENT=$(echo "$OPACITY * 100" | bc | sed 's/\..*$//')
  echo "[${PERCENT}%]"
else
  echo "[80%]"
fi
