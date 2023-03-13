#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C
script_basename="$(basename "$0")"
script_dir="$(cd "$(dirname "$0")"; pwd)"
script_path="${script_dir}"/"${script_basename}"
cd "${script_dir}"
start_time=$(date +%s.%N)

# sudo sed -i -e "s/^# deb-src/deb-src/" /etc/apt/sources.list
# sudo apt update
sudo apt build-dep -y vim
cd /usr/local/src/
if [ ! -d ./vim/ ]; then
  sudo git clone https://github.com/vim/vim.git
fi

end_time=$(date +%s.%N)
wall_time=$(echo "${end_time}"-"${start_time}" | bc -l)
echo ["${script_path}"] WallTime: "${wall_time}" [s]
