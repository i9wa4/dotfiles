#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C
script_basename="$(basename "$0")"
script_dir="$(cd "$(dirname "$0")"; pwd)"
script_path="${script_dir}"/"${script_basename}"
cd "${script_dir}"
start_time=$(date +%s.%N)

# Symbolic Link
rm -rf "{HOME}"/.config && mkdir -p "${HOME}"/.config
rm -rf "{HOME}"/.vim
cp -rfs "${HOME}"/dotfiles/etc/home/.   "${HOME}"
cp -rfs "${HOME}"/dotfiles/.nvim/.      "${HOME}"/.config
ln -fs  "${HOME}"/dotfiles/.vim         "${HOME}"/.vim
sudo ln -fs "${HOME}"/dotfiles/etc/wsl.conf /etc/wsl.conf
mkdir -p "/mnt/c/work/"
ln -s "/mnt/c/work/" "${HOME}"/work

# .bashrc
cat << EOT >> "${HOME}"/.bashrc
if [ -f "${HOME}"/dotfiles/etc/.bashrc ]; then
  . "${HOME}"/dotfiles/etc/.bashrc
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
  tmux \
  unzip \
  vim \
  zip

# Git
bash git_config.sh

end_time=$(date +%s.%N)
wall_time=$(echo "${end_time}"-"${start_time}" | bc -l)
echo ["${script_path}"] WallTime: "${wall_time}" [s]
