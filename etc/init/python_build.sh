#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C
cd "$(dirname "$0")"
start_time=$(date +%s.%N)

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

end_time=$(date +%s.%N)
wall_time=$(echo "${end_time}"-"${start_time}" | bc -l)
cd "$(dirname "$0")"
echo ["$(realpath "$0")"] WallTime: "${wall_time}" [s]
