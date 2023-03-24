#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

# sudo sed -i -e "s/^# deb-src/deb-src/" /etc/apt/sources.list
# sudo apt update
sudo apt build-dep -y vim
cd /usr/local/src/
if [ ! -d ./vim/ ]; then
  sudo git clone https://github.com/vim/vim.git
fi