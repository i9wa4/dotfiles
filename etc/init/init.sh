#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C
script_basename="$(basename "$0")"
script_dir="$(cd "$(dirname "$0")"; pwd)"
script_path="${script_dir}"/"${script_basename}"
cd "${script_dir}"
start_time=$(date +%s.%N)

# Symbolic Link
rm -rf "{HOME}"/.config
rm -rf "{HOME}"/.vim
mkdir -p "${HOME}"/.config
ln -s "${HOME}"/dotfiles/.gitignore       "${HOME}"/.gitignore
ln -s "${HOME}"/dotfiles/.markdownlintrc  "${HOME}"/.markdownlintrc
ln -s "${HOME}"/dotfiles/.nvim/my_nvim    "${HOME}"/.config/my_nvim
ln -s "${HOME}"/dotfiles/.vim             "${HOME}"/.vim
ln -s "${HOME}"/dotfiles/etc/markdown_style.css "${HOME}"/markdown_style.css
ln -s "${HOME}"/dotfiles/jupytext.yaml    "${HOME}"/jupytext.yaml
sudo ln -s "${HOME}"/dotfiles/wsl.conf /etc/wsl.conf
mkdir -p "/mnt/c/work/"
ln -s "/mnt/c/work/" "${HOME}"/work

# .bashrc
cat << EOT >> "${HOME}"/.bashrc
if [ -f "${HOME}"/dotfiles/.bashrc ]; then
  . "${HOME}"/dotfiles/.bashrc
fi
EOT

# General
sudo add-apt-repository -y ppa:git-core/ppa
sudo sed -i -e "s/^# deb-src/deb-src/" /etc/apt/sources.list
sudo apt update
sudo apt upgrade -y
sudo apt install -y \
  bc \
  nkf \
  ripgrep \
  unzip \
  vim \
  zip

# Git
bash git_config.sh

end_time=$(date +%s.%N)
wall_time=$(echo "${end_time}"-"${start_time}" | bc -l)
echo ["${script_path}"] WallTime: "${wall_time}" [s]
