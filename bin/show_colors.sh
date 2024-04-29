#!/usr/bin/env zsh
set -euox pipefail -o posix

# background colors
for C in {0..255}; do
    tput setab "$C"
    echo -n "$C "
done
tput sgr0
echo

# foreground colors
for C in {0..255}; do
    tput setaf "$C"
    echo -n "$C "
done
tput sgr0
echo
