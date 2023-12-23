#!/usr/bin/env bash
set -euxo pipefail

script_basename=$(basename "$0")
script_dir=$(cd $(dirname "$0"); pwd)
script_path="${script_dir}"/"${script_basename}"
cd "${script_dir}"
start_time=$(date +%s.%N)

sudo apt update
sudo apt install -y \
  bc \
  make

make minimal

end_time=$(date +%s.%N)
wall_time=$(echo "${end_time}"-"${start_time}" | bc -l)
echo ["${script_path}"] WallTime: "${wall_time}" [s]
