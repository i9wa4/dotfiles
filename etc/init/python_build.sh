#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C
script_basename="$(basename "$0")"
script_dir="$(cd "$(dirname "$0")"; pwd)"
script_path="${script_dir}"/"${script_basename}"
cd "${script_dir}"
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
echo ["${script_path}"] WallTime: "${wall_time}" [s]
