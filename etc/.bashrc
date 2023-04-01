#!/usr/bin/env bash
export LC_ALL=C.UTF-8
export XDG_CONFIG_HOME="${HOME}"/.config

# Editor
export EDITOR=vim
export NVIM_APPNAME=my_nvim
export VISUAL=vim
set -o vi

# Deno
export DENO_TLS_CA_STORE="system"
export DENO_INSTALL="${HOME}"/.deno
export PATH="${DENO_INSTALL}"/bin:"${PATH}"

# Go
export GOPATH="${HOME}"/go
mkdir -p "${GOPATH}"
export PATH="${GOPATH}"/bin:"${PATH}"

# Python
export PY_VER_MINOR=3.11
export PY_VER_PATCH=3.11.2
export VENV_MYENV="${HOME}"/venv/myenv


# display git branch
if [ -f /etc/bash_completion ]; then
  . /etc/bash_completion
fi
if [ -f /etc/bash_completion.d/git-prompt ]; then
  export PS1='\[\033[01;32m\]\u@\h\[\033[01;33m\] \w$(__git_ps1) \n\[\033[01;34m\]\$\[\033[00m\] '
else
  export PS1='\[\033[01;32m\]\u@\h\[\033[01;33m\] \w \n\[\033[01;34m\]\$\[\033[00m\] '
fi


# .bash_aliases
alias py-vma='. "${VENV_MYENV}"/bin/activate'
alias jl='
rm -rf "${HOME}"/.ipynb_checkpoints \
&& cp -rf "${HOME}"/dotfiles/.jupyter/* "${VENV_MYENV}"/share/jupyter \
&& jupyter-lab \
  --no-browser \
  --ServerApp.use_redirect_file=False \
  --FileCheckpoints.checkpoint_dir="${HOME}"/.ipynb_checkpoints \
'
alias rmarkdown-render='
find . -name "*.md" -type f -printf "%f\n" \
| xargs -I {} R -e "rmarkdown::render(\"{}\", output_dir=\"..\")" \
'
