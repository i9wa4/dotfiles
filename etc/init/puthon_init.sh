#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C
cd "$(dirname "$0")"
start_time=$(date +%s.%N)

# https://devguide.python.org/getting-started/setup-building/#build-dependencies
# sudo sed -i -e "s/^# deb-src/deb-src/" /etc/apt/sources.list
# sudo apt update
sudo apt build-dep -y python3
sudo apt install -y \
  build-essential gdb lcov pkg-config \
  libbz2-dev libffi-dev libgdbm-dev libgdbm-compat-dev liblzma-dev \
  libncurses5-dev libreadline6-dev libsqlite3-dev libssl-dev \
  lzma lzma-dev tk-dev uuid-dev zlib1g-dev
cd /usr/local/src/
if [ ! -d ./cpython/ ]; then
  sudo git clone https://github.com/python/cpython.git
fi

end_time=$(date +%s.%N)
wall_time=$(echo "${end_time}"-"${start_time}" | bc -l)
cd "$(dirname "$0")"
echo ["$(realpath "$0")"] WallTime: "${wall_time}" [s]
