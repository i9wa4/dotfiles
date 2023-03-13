#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C
script_basename="$(basename "$0")"
script_dir="$(cd "$(dirname "$0")"; pwd)"
script_path="${script_dir}"/"${script_basename}"
cd "${script_dir}"
start_time=$(date +%s.%N)

. "${HOME}"/.my_bashrc

if [ -d "${VENV_MYENV}" ]; then
  python"${PY_VER_MINOR}" -m venv "${VENV_MYENV}" --upgrade
else
  python"${PY_VER_MINOR}" -m venv "${VENV_MYENV}"
fi

. "${VENV_MYENV}"/bin/activate
python"${PY_VER_MINOR}" -m pip config --site set global.trusted-host "pypi.org pypi.python.org files.pythonhosted.org"
python"${PY_VER_MINOR}" -m pip install --upgrade pip setuptools wheel
python"${PY_VER_MINOR}" -m pip install -r "${HOME}"/dotfiles/etc/init/requirements.txt
python"${PY_VER_MINOR}" -m pip check
deactivate

end_time=$(date +%s.%N)
wall_time=$(echo "${end_time}"-"${start_time}" | bc -l)
echo ["${script_path}"] WallTime: "${wall_time}" [s]
