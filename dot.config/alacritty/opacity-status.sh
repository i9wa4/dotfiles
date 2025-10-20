#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail
set -o posix

OPACITY_FILE="$HOME/.config/alacritty/opacity.toml"
DEFAULT_OPACITY=1.0

if [[ -f $OPACITY_FILE ]]; then
  OPACITY=$(grep "^opacity" "$OPACITY_FILE" | sed 's/.*= *//')
  echo "$OPACITY"
else
  echo "$DEFAULT_OPACITY"
fi
