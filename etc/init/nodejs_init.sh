#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C
script_basename="$(basename "$0")"
script_dir="$(cd "$(dirname "$0")"; pwd)"
script_path="${script_dir}"/"${script_basename}"
cd "${script_dir}"
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
echo ["${script_path}"] WallTime: "${wall_time}" [s]
