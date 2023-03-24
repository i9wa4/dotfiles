#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

WIN_UTIL_DIR=/mnt/c/work/util/
rm -rf "${WIN_UTIL_DIR}"
mkdir -p "${WIN_UTIL_DIR}"
cp -rf "${HOME}"/dotfiles/.jupyter/             "${WIN_UTIL_DIR}"
cp -rf "${HOME}"/dotfiles/.nvim/my_nvim/vsnip/  "${WIN_UTIL_DIR}"
cp -rf "${HOME}"/dotfiles/VSCode/               "${WIN_UTIL_DIR}"
cp -rf "${HOME}"/dotfiles/WindowsTerminal/      "${WIN_UTIL_DIR}"
cp -rf "${HOME}"/dotfiles/etc/home/*            "${WIN_UTIL_DIR}"
cp -rf "${HOME}"/dotfiles/etc/windows/*         "${WIN_UTIL_DIR}"