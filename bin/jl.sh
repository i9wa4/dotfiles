#!/usr/bin/env bash
set -euo pipefail

rm -rf "${HOME}"/.ipynb_checkpoints
cd $1
jupyter-lab \
  --config="${XDG_CONFIG_HOME}"/jupyter/jupyter_lab_config.py \
  --FileCheckpoints.checkpoint_dir="${HOME}"/.ipynb_checkpoints
