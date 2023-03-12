#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C
cd "$(dirname "$0")"

git config --global commit.verbose true
git config --global core.autocrlf input
git config --global core.editor vim
git config --global core.excludesfile ~/.gitignore
git config --global core.pager "LESSCHARSET=utf-8 less"
git config --global core.quotepath false
git config --global credential.helper store
git config --global diff.compactionHeuristic true
git config --global diff.tool vimdiff
git config --global difftool.prompt false
git config --global difftool.vimdiff.path vim
git config --global grep.lineNumber true
git config --global http.sslVerify false
git config --global merge.conflictstyle diff3
git config --global merge.tool vimdiff
git config --global mergetool.prompt false
git config --global mergetool.vimdiff.path vim
git config --global push.default current
# git config --global user.email foo@bar.com
# git config --global user.name foo
