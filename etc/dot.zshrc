autoload -Uz compinit promptinit
compinit
promptinit

prompt walters

# editor
# set -o vi

# aliases
alias ll='ls -alFv'
alias py-vma='. "${PY_VENV_MYENV}"/bin/activate'
alias jl='zsh "${HOME}"/dotfiles/bin/jl.sh "$(pwd)"'
alias rmarkdown-render='zsh "${HOME}"/dotfiles/bin/rmarkdown_render.sh "$(pwd)"'

# Git
# https://hirooooo-lab.com/development/git-terminal-customize-zsh/
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst
# RPROMPT=\$vcs_info_msg_0_
# PROMPT=\$vcs_info_msg_0_'%# '
zstyle ':vcs_info:git:*' formats '%b'

# Homebrew
export PATH=/opt/homebrew/bin:"${PATH}"
export DYLD_LIBRARY_PATH=/opt/homebrew/lib

# AWS
export AWS_DEFAULT_PROFILE=

# local env
# export VOLTA_HOME="${HOME}"/.volta
# export PATH="${VOLTA_HOME}"/bin:"${PATH}"
# export PATH="${HOME}"/.rbenv/bin:"${PATH}"
# eval "$(rbenv init - zsh)"

# tmux
# https://qiita.com/kiwi-bird/items/7f1a77faf6b0ab0df571
alias tmux="tmux -u2"
count=$(ps aux | grep tmux | grep -v grep | wc -l)
if test "${count}" -eq 0; then
    echo $(tmux)
elif test "${count}" -eq 1; then
    echo $(tmux a)
fi
