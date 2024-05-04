#!/usr/bin/env zsh
set -euo pipefail
setopt xtrace posix err_exit

rm -rf "${HOME}"/.ipynb_checkpoints
rm -rf "${HOME}"/.virtual_documents
cp -rf "${HOME}"/dotfiles/dot.config/jupyter/* "${PY_VENV_MYENV}"/share/jupyter
cd "$1"
jupyter-lab \
  --config="${XDG_CONFIG_HOME}"/jupyter/jupyter_lab_config.py \
  --FileCheckpoints.checkpoint_dir="${HOME}"/.ipynb_checkpoints
