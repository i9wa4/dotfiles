#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C


# background colors
for C in {0..255}; do
    tput setab $C
    echo -n "$C "
done
tput sgr0
echo

# foreground colors
for C in {0..255}; do
    tput setaf $C
    echo -n "$C "
done
tput sgr0
echo
