#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C
cd "$(dirname "$0")"

. "${HOME}"/.my_bashrc

# WIN_HOME=/mnt/c/Users/"${USER}"
# cp -f "${HOME}"/dotfiles/.gitignore "${WIN_HOME}"
# cp -f "${HOME}"/dotfiles/.wslconfig "${WIN_HOME}"

# WIN_WORK=/mnt/c/work
# mkdir -p "${WIN_WORK}"
# cp -f "${HOME}"/dotfiles/.markdownlintrc "${WIN_WORK}"
# cp -f "${HOME}"/dotfiles/jupytext.yaml "${WIN_WORK}"

# CODE_DIR="${WIN_HOME}"/AppData/Roaming/Code/User
# rm -rf "${CODE_DIR}/snippets/"
# mkdir -p "${CODE_DIR}"/snippets/
# cp -f "${HOME}"/dotfiles/VSCode/User/* "${CODE_DIR}"
# cp -f "${HOME}"/dotfiles/.vim/vsnip/* "${CODE_DIR}"/snippets/

# WINTERM_DIR="${WIN_HOME}"/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState
# rm -rf "${WINTERM_DIR}"
# mkdir -p "${WINTERM_DIR}"
# cp -f "${HOME}"/dotfiles/WindowsTerminal/LocalState/* "${WINTERM_DIR}"

# WIN_UTIL_DIR=/mnt/c/work/util/
# rm -rf "${WIN_UTIL_DIR}"
# mkdir -p "${WIN_UTIL_DIR}"
# cp -f "${HOME}"/dotfiles/etc/windows/* "${WIN_UTIL_DIR}"
# cp -rf "${HOME}"/dotfiles/.jupyter/ "${WIN_UTIL_DIR}"
