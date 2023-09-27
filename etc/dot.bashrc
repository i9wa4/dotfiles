# Editor
set -o vi
export EDITOR=vim
export VISUAL=vim

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
alias py-vma='. "${PY_VENV_MYENV}"/bin/activate'
alias jl='
rm -rf "${HOME}"/.ipynb_checkpoints \
&& cp -rf "${HOME}"/dotfiles/.jupyter/* "${PY_VENV_MYENV}"/share/jupyter \
&& jupyter-lab \
  --no-browser \
  --ServerApp.use_redirect_file=False \
  --FileCheckpoints.checkpoint_dir="${HOME}"/.ipynb_checkpoints \
'
alias rmarkdown-render='
find "$(pwd)" -maxdepth 2 -name "*.Rmd" -type f \
| xargs -I {} echo {} \
| xargs -I {} R -e "rmarkdown::render(\"{}\", output_dir=\""$(dirname {})"\")" \
'
