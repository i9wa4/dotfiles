#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C
script_basename="$(basename "$0")"
script_dir="$(cd "$(dirname "$0")"; pwd)"
script_path="${script_dir}"/"${script_basename}"
cd "${script_dir}"
start_time=$(date +%s.%N)

# General
sudo sed -i -e "s/^# deb-src/deb-src/" /etc/apt/sources.list
sudo apt update
sudo apt upgrade -y
sudo apt install -y \
  bc \
  unzip \
  zip

# Symbolic Link
rm -rf "{HOME}"/.config
rm -rf "{HOME}"/.vim
mkdir -p "${HOME}"/.config
ln -s "${HOME}"/dotfiles/.gitignore       "${HOME}"/.gitignore
ln -s "${HOME}"/dotfiles/.markdownlintrc  "${HOME}"/.markdownlintrc
ln -s "${HOME}"/dotfiles/.my_bashrc       "${HOME}"/.my_bashrc
ln -s "${HOME}"/dotfiles/.vim             "${HOME}"/.config/nvim
ln -s "${HOME}"/dotfiles/.vim             "${HOME}"/.vim
ln -s "${HOME}"/dotfiles/etc/markdown_style.css "${HOME}"/markdown_style.css
ln -s "${HOME}"/dotfiles/jupytext.yaml    "${HOME}"/jupytext.yaml
if [ -n "$(which wslpath)" ]; then
  sudo ln -s "${HOME}"/dotfiles/wsl.conf /etc/wsl.conf
  mkdir -p "/mnt/c/work/"
  ln -s "/mnt/c/work/" "${HOME}"/work
fi
{
  echo "if [ -f ""${HOME}""/.my_bashrc ]; then"
  echo "  . ""${HOME}""/.my_bashrc"
  echo "fi"
} >> "${HOME}"/.bashrc
. "${HOME}"/.my_bashrc

# Git
sudo add-apt-repository -y ppa:git-core/ppa
sudo apt update
sudo apt upgrade -y
bash git_config.sh

# Vim
# sudo sed -i -e "s/^# deb-src/deb-src/" /etc/apt/sources.list
# sudo apt update
sudo apt build-dep -y vim
sudo apt install -y ripgrep
cd /usr/local/src/
if [ ! -d ./vim/ ]; then
  sudo git clone https://github.com/vim/vim.git
fi
cd -

# Neovim
# https://github.com/neovim/neovim/wiki/Building-Neovim
# sudo apt update
sudo apt install -y \
  autoconf \
  automake \
  cmake \
  cmake \
  curl \
  doxygen \
  g++ \
  gcc \
  gettext \
  libtool \
  libtool-bin \
  ninja-build \
  pkg-config \
  unzip \
sudo apt install -y nkf
sudo apt install -y shellcheck
cd /usr/local/src/
if [ ! -d ./neovim/ ]; then
  sudo git clone https://github.com/neovim/neovim.git
fi
cd -

# Deno
if [ -z "$(which deno)" ]; then
  curl -fsSL https://deno.land/install.sh | bash
fi

# SKK
mkdir -p "${HOME}"/.skk/
cd "${HOME}"/.skk/
wget http://openlab.jp/skk/dic/SKK-JISYO.L.gz
gzip -d SKK-JISYO.L.gz
wget http://openlab.jp/skk/dic/SKK-JISYO.jinmei.gz
gzip -d SKK-JISYO.jinmei.gz
cd -

# Script
bash vim_build.sh
bash nvim_build.sh
bash win_update.sh

end_time=$(date +%s.%N)
wall_time=$(echo "${end_time}"-"${start_time}" | bc -l)
echo ["${script_path}"] WallTime: "${wall_time}" [s]
