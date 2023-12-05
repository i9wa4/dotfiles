# Editor
set -o vi

if [ -f /etc/bash_completion ]; then
  . /etc/bash_completion
fi

# display git branch
if [ -f /etc/bash_completion.d/git-prompt ]; then
  . /etc/bash_completion.d/git-prompt
  COLOR_USER_HOST="$(tput setaf 2)"
  COLOR_PWD="$(tput setaf 3)"
  COLOR_GIT="$(tput setaf 1)"
  COLOR_PROMPT="$(tput setaf 4)"
  COLOR_RESET="$(tput sgr0)"
  PS1='\n${debian_chroot:+($debian_chroot)}\[${COLOR_USER_HOST}\]\u@\h\[${COLOR_RESET}\]:\[${COLOR_PWD}\]\w\[${COLOR_GIT}\]$(__git_ps1)\n\[${COLOR_PROMPT}\]$ \[${COLOR_RESET}\]'
  if [ -n "${MYVIMRC}" ]; then
    PS1='\n\[${COLOR_PROMPT}\]$ \[${COLOR_RESET}\]'
  fi
fi

# .bash_aliases
alias py-vma='. "${PY_VENV_MYENV}"/bin/activate'
alias jl='
rm -rf "${HOME}"/.ipynb_checkpoints \
&& cp -rf "${HOME}"/dotfiles/dot.jupyter/* "${PY_VENV_MYENV}"/share/jupyter \
&& jupyter-lab \
  --no-browser \
  --ServerApp.use_redirect_file=False \
  --FileCheckpoints.checkpoint_dir="${HOME}"/.ipynb_checkpoints \
'
alias rmarkdown-render='
bash "${HOME}"/dotfiles/bin/rmarkdown_render.sh "$(pwd)" \
'
