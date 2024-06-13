#!/usr/bin/env bash
set -euox pipefail -o posix

git -C "${HOME}"/dotfiles fetch &

for repo_path in "${HOME}"/src/*; do
  git -C "${repo_path}" fetch &
done
