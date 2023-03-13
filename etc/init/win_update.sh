#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C
cd "$(dirname "$0")"

WIN_UTIL_DIR=/mnt/c/work/util/
rm -rf "${WIN_UTIL_DIR}"
mkdir -p "${WIN_UTIL_DIR}"
cp -rf "${HOME}"/dotfiles/etc/windows/*     "${WIN_UTIL_DIR}"
cp -rf "${HOME}"/dotfiles/.jupyter/         "${WIN_UTIL_DIR}"
cp -rf "${HOME}"/dotfiles/.markdownlintrc   "${WIN_UTIL_DIR}"
cp -rf "${HOME}"/dotfiles/jupytext.yaml     "${WIN_UTIL_DIR}"
cp -rf "${HOME}"/dotfiles/.gitignore        "${WIN_UTIL_DIR}"
cp -rf "${HOME}"/dotfiles/.wslconfig        "${WIN_UTIL_DIR}"
cp -rf "${HOME}"/dotfiles/VSCode/           "${WIN_UTIL_DIR}"
cp -rf "${HOME}"/dotfiles/.vim/vsnip/       "${WIN_UTIL_DIR}"
cp -rf "${HOME}"/dotfiles/WindowsTerminal/  "${WIN_UTIL_DIR}"
