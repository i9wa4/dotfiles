#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

. "${HOME}"/dotfiles/etc/.bashrc

# Go
sudo add-apt-repository -y ppa:longsleep/golang-backports
sudo apt update
sudo apt install -y golang-go
mkdir -p "${GOPATH}"
go install github.com/rhysd/vim-startuptime@latest
# $ vim-startuptime -vimpath nvim -count 1000
# $ vim-startuptime -vimpath vim -count 1000
