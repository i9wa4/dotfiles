#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
set -o posix

# Toggle terminal theme between dark and light mode.
# Stores current theme in cache file.
#
# Usage:
#   terminal-theme-toggle.sh
#
# Cache file:
#   $XDG_CACHE_HOME/terminal-theme (default: ~/.cache/terminal-theme)

CACHE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/terminal-theme"

# Get current theme
if [[ -f "$CACHE_FILE" ]]; then
  current=$(tr -d ' \n' <"$CACHE_FILE")
else
  current="dark"
fi

# Toggle theme
if [[ "$current" == "dark" ]]; then
  echo "light" >"$CACHE_FILE"
else
  echo "dark" >"$CACHE_FILE"
fi
