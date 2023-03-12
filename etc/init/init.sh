#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C
cd "$(dirname "$0")"
start_time=$(date +%s.%N)

# General
sudo sed -i -e "s/^# deb-src/deb-src/" /etc/apt/sources.list
sudo apt update
sudo apt upgrade -y
sudo apt install -y \
  bc \
  ripgrep \
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
bash "${HOME}"/dotfies/etc/init/git_config.sh

# Node.js/npm
# https://github.com/nodesource/distributions/blob/master/README.md#debinstall
# https://github.com/nodesource/distributions/issues/1157
cd /etc/apt/sources.list.d
sudo rm -f nodesource.list
curl -fsSL https://deb.nodesource.com/setup_19.x | sudo -E bash -
sudo apt update
sudo apt install -y nodejs

# Vim
# sudo sed -i -e "s/^# deb-src/deb-src/" /etc/apt/sources.list
# sudo apt update
sudo apt build-dep -y vim
# sudo apt install -y ripgrep
cd /usr/local/src/
if [ ! -d ./vim/ ]; then
  sudo git clone https://github.com/vim/vim.git
fi

# Neovim
# https://github.com/neovim/neovim/wiki/Building-Neovim
# sudo apt update
sudo apt install -y gcc cmake
sudo apt install -y \
  ninja-build gettext libtool libtool-bin autoconf automake cmake g++ \
  pkg-config unzip curl doxygen
sudo apt install -y shellcheck
sudo npm install -g markdownlint-cli
sudo curl -L https://github.com/hadolint/hadolint/releases/download/v2.12.0/hadolint-Linux-x86_64 -o /usr/local/bin/hadolint
sudo chmod 755 /usr/local/bin/hadolint
cd /usr/local/src/
if [ ! -d ./neovim/ ]; then
  sudo git clone https://github.com/neovim/neovim.git
fi

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

# Python
# https://devguide.python.org/getting-started/setup-building/#build-dependencies
# sudo sed -i -e "s/^# deb-src/deb-src/" /etc/apt/sources.list
# sudo apt update
sudo apt build-dep -y python3
sudo apt install -y \
  build-essential gdb lcov pkg-config \
  libbz2-dev libffi-dev libgdbm-dev libgdbm-compat-dev liblzma-dev \
  libncurses5-dev libreadline6-dev libsqlite3-dev libssl-dev \
  lzma lzma-dev tk-dev uuid-dev zlib1g-dev
cd /usr/local/src/
if [ ! -d ./cpython/ ]; then
  sudo git clone https://github.com/python/cpython.git
fi

# Script
bash "${HOME}"/dotfies/etc/init/vim_build.sh
bash "${HOME}"/dotfies/etc/init/nvim_build.sh
bash "${HOME}"/dotfies/etc/init/python_build.sh
bash "${HOME}"/dotfies/etc/init/python_venv_myenv.sh
bash "${HOME}"/dotfies/etc/init/win_update.sh

end_time=$(date +%s.%N)
wall_time=$(echo "${end_time}"-"${start_time}" | bc -l)
cd "$(dirname "$0")"
echo ["$(realpath "$0")"] WallTime: "${wall_time}" [s]
