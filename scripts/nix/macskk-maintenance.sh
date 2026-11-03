#!/usr/bin/env bash
set -euo pipefail

action=${1:?expected pin-existing or upgrade}
brew_path=${2:-}
if [ -z "$brew_path" ]; then
  if ! brew_path=$(command -v brew); then
    printf 'Homebrew is not available on PATH.\n' >&2
    exit 127
  fi
fi

pin() {
  HOMEBREW_NO_AUTO_UPDATE=1 "$brew_path" pin --cask macskk
}

case "$action" in
pin-existing)
  # Listing all installed casks distinguishes a fresh install from a failed
  # query. A query/pin error must stop activation before Bundle upgrades.
  installed=$(HOMEBREW_NO_AUTO_UPDATE=1 "$brew_path" list --cask)
  while IFS= read -r cask; do
    if [ "$cask" = macskk ]; then
      pin
      break
    fi
  done <<<"$installed"
  ;;
upgrade)
  # Verify installation and pin support before temporarily removing the pin.
  pin
  restore_pin() {
    status=$?
    trap - EXIT INT TERM HUP
    if ! pin; then
      printf 'ERROR: could not restore the macSKK pin; re-pin it before the next switch.\n' >&2
      if [ "$status" -eq 0 ]; then
        status=1
      fi
    fi
    exit "$status"
  }
  trap restore_pin EXIT
  trap 'exit 130' INT
  trap 'exit 143' TERM
  trap 'exit 129' HUP
  HOMEBREW_NO_AUTO_UPDATE=1 "$brew_path" unpin --cask macskk
  "$brew_path" upgrade --cask macskk
  printf 'macSKK package upgrade completed. Current-session input may still require logout/login.\n'
  ;;
*)
  printf 'Expected pin-existing or upgrade.\n' >&2
  exit 2
  ;;
esac
