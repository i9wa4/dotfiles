#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail
set -o posix

OPACITY_FILE="$HOME/.config/alacritty/opacity.toml"
DEFAULT_OPACITY=1.0

if [[ -f $OPACITY_FILE ]]; then
  OPACITY=$(grep "^opacity" "$OPACITY_FILE" | sed 's/.*= *//')
  printf "%.1f\n" "$OPACITY"
else
  printf "%.1f\n" "$DEFAULT_OPACITY"
fi
