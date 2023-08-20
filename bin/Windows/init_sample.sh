#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

# local.vim
cat << EOT | tee "${HOME}"/local.vim /mnt/c/work/local.vim
scriptencoding utf-8

let g:my_bookmark_path = expand('~/work/bookmark.md')
let g:my_gtd_path = expand('~/work/gtd.md')
let g:local_vim_setting_name = fnamemodify(expand('<sfile>'), ":h:t")
EOT

# [WSL2]
# sudo mkdir -p /mnt/ad/
# cat <<EOT | tee -a "${HOME}"/.bashrc
# alias mntad='sudo mount -t drvfs '//ip/dir' /mnt/ad/'
# cd
# EOT

# [Git for Windows]
# add the followings to /etc/bash.bashrc
# alias mntad='mount -t drvfs '//ip/dir' /mnt/ad/'

# Git
# git config --global user.email "${USER}"
# git config --global user.name "${USER}"

# setup
sudo apt install -y \
  bc \
  make
