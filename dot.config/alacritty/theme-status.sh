#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail
set -o posix

THEME_FILE="$HOME/.config/alacritty/theme.toml"

if [[ -f $THEME_FILE ]]; then
  THEME=$(grep "themes/themes/" "$THEME_FILE" | sed "s/.*themes\/themes\/\(.*\)\.toml.*/\1/")
  if [[ -n $THEME ]]; then
    echo "$THEME"
  else
    echo "unknown"
  fi
else
  echo "no-theme"
fi
