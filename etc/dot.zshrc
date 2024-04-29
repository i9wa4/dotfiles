autoload -Uz compinit promptinit
compinit
promptinit

prompt walters

# editor
set -o vi

# aliases
alias ll='ls -alFv'
alias py-vma='. "${PY_VENV_MYENV}"/bin/activate'
alias jl='zsh "${HOME}"/dotfiles/bin/jl.sh "$(pwd)"'
alias rmarkdown-render='zsh "${HOME}"/dotfiles/bin/rmarkdown_render.sh "$(pwd)"'

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
# https://qiita.com/ssh0/items/a9956a74bff8254a606a
if [[ ! -n "${TMUX}" ]]; then
  # get the IDs
  ID="$(tmux list-sessions)"
  if [[ -z "${ID}" ]]; then
    tmux new-session
  fi
  ID="$(echo "${ID}" | "${PERCOL}" | cut -d: -f1)"
  tmux attach-session -t "${ID}"
fi
