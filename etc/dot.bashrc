if [ -z "${PS1}" ]; then
  # non-interactive shell
  return
fi

# editor
set -o vi

# completion
if [ -f /etc/bash_completion ]; then
  . /etc/bash_completion
fi

# display git branch
if [ -f /etc/bash_completion.d/git-prompt ]; then
  . /etc/bash_completion.d/git-prompt

  _SHELL_TYPE="$(ps -o comm -p $$ | tail -n 1 | sed -e 's/.*\///g')"
  _CL_USER_HOST_LOCAL="$(tput setaf 2)"
  _CL_USER_HOST_REMOTE="$(tput setaf 1)"
  _CL_SH="$(tput setaf 8)"
  _CL_PWD="$(tput setaf 3)"
  _CL_GIT="$(tput setaf 5)"
  _CL_PROMPT="$(tput setaf 4)"
  _CL_RESET="$(tput sgr0)"

  PS1='${debian_chroot:+($debian_chroot)}'
  if [ -n "${MYVIMRC}" ]; then
    PS1="${PS1}\n\[${_CL_PROMPT}\]$\[${_CL_RESET}\] "
  else
    if [[ -n "${SSH_CONNECTION}" || -n "${SSH_TTY}" || -n "${SSH_CLIENT}" ]]; then
      # remote host
      PS1="${PS1}"'\[${_CL_USER_HOST_REMOTE}\]\u@\H'
    else
      # local host
      PS1="${PS1}"'\[${_CL_USER_HOST_LOCAL}\]\u@\H'
    fi
    PS1="${PS1}"' \[${_CL_SH}\](${_SHELL_TYPE} Lv${SHLVL})\[${_CL_RESET}\]:'
    PS1="${PS1}"' \[${_CL_PWD}\]\w'
    PS1="${PS1}"'\[${_CL_GIT}\]$(__git_ps1)'
    PS1="${PS1}"'\n\[${_CL_PROMPT}\]$\[${_CL_RESET}\] '
  fi
fi

# .bash_aliases
alias py-vma='. "${PY_VENV_MYENV}"/bin/activate'
alias jl='
bash "${HOME}"/dotfiles/bin/jl.sh "$(pwd)" \
'
# # && cp -rf "${HOME}"/dotfiles/dot.config/jupyter/* "${PY_VENV_MYENV}"/share/jupyter \
# # --no-browser \
# # --ServerApp.use_redirect_file=False \
# # --FileCheckpoints.checkpoint_dir="${HOME}"/.ipynb_checkpoints \
# rm -rf "${HOME}"/.ipynb_checkpoints \
# && jupyter-lab \
#   --config="${XDG_CONFIG_HOME}"/jupyter/jupyter_lab_config.py \
#   --FileCheckpoints.checkpoint_dir="${HOME}"/.ipynb_checkpoints \
# '
alias rmarkdown-render='
bash "${HOME}"/dotfiles/bin/rmarkdown_render.sh "$(pwd)" \
'
