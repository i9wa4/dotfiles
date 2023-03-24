#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

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
  unzip
sudo apt install -y shellcheck
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