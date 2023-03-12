#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C
cd "$(dirname "$0")"
start_time=$(date +%s.%N)

cd /usr/local/src/neovim/
sudo git checkout master
sudo git pull
sudo make CMAKE_BUILD_TYPE=Release
sudo make install

end_time=$(date +%s.%N)
wall_time=$(echo "${end_time}"-"${start_time}" | bc -l)
cd "$(dirname "$0")"
echo ["$(realpath "$0")"] WallTime: "${wall_time}" [s]
