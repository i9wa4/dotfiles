#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C
script_basename="$(basename "$0")"
script_dir="$(cd "$(dirname "$0")"; pwd)"
script_path="${script_dir}"/"${script_basename}"
cd "${script_dir}"
start_time=$(date +%s.%N)

cd /usr/local/src/vim/
sudo git checkout master
sudo git pull
cd ./src/
sudo ./configure \
  --disable-gui \
  --enable-fail-if-missing \
  --enable-python3interp=dynamic \
  --prefix=/usr/local \
  --with-features=huge \
  --with-x
sudo make
sudo make install
hash -r

end_time=$(date +%s.%N)
wall_time=$(echo "${end_time}"-"${start_time}" | bc -l)
echo ["${script_path}"] WallTime: "${wall_time}" [s]
