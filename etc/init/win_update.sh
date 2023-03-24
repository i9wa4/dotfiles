#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C
script_basename="$(basename "$0")"
script_dir="$(cd "$(dirname "$0")"; pwd)"
script_path="${script_dir}"/"${script_basename}"
cd "${script_dir}"
start_time=$(date +%s.%N)

WIN_UTIL_DIR=/mnt/c/work/util/
rm -rf "${WIN_UTIL_DIR}"
mkdir -p "${WIN_UTIL_DIR}"
cp -rf "${HOME}"/dotfiles/.gitignore              "${WIN_UTIL_DIR}"
cp -rf "${HOME}"/dotfiles/.jupyter/               "${WIN_UTIL_DIR}"
cp -rf "${HOME}"/dotfiles/.markdownlintrc         "${WIN_UTIL_DIR}"
cp -rf "${HOME}"/dotfiles/.nvim/my_nvim/vsnip/    "${WIN_UTIL_DIR}"
cp -rf "${HOME}"/dotfiles/.wslconfig              "${WIN_UTIL_DIR}"
cp -rf "${HOME}"/dotfiles/VSCode/                 "${WIN_UTIL_DIR}"
cp -rf "${HOME}"/dotfiles/WindowsTerminal/        "${WIN_UTIL_DIR}"
cp -rf "${HOME}"/dotfiles/etc/windows/*           "${WIN_UTIL_DIR}"
cp -rf "${HOME}"/dotfiles/jupytext.yaml           "${WIN_UTIL_DIR}"
cp -rf "${HOME}"/dotfiles/etc/markdown_style.css  "${WIN_UTIL_DIR}"

end_time=$(date +%s.%N)
wall_time=$(echo "${end_time}"-"${start_time}" | bc -l)
echo ["${script_path}"] WallTime: "${wall_time}" [s]
