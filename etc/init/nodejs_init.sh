#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C
cd "$(dirname "$0")"
start_time=$(date +%s.%N)

# Node.js/npm
# https://github.com/nodesource/distributions/blob/master/README.md#debinstall
# https://github.com/nodesource/distributions/issues/1157
cd /etc/apt/sources.list.d
sudo rm -f nodesource.list
curl -fsSL https://deb.nodesource.com/setup_19.x | sudo -E bash -
sudo apt update
sudo apt install -y nodejs
sudo npm install -g markdownlint-cli

end_time=$(date +%s.%N)
wall_time=$(echo "${end_time}"-"${start_time}" | bc -l)
cd "$(dirname "$0")"
echo ["$(realpath "$0")"] WallTime: "${wall_time}" [s]
