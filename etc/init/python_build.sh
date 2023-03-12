#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C
cd "$(dirname "$0")"

. "${HOME}"/.my_bashrc

cd /usr/local/src/cpython/
sudo git checkout main
sudo git fetch
sudo git merge
sudo git checkout refs/tags/v"${PY_VER_PATCH}"
sudo ./configure
sudo make
sudo make altinstall
python"${PY_VER_MINOR}" --version
