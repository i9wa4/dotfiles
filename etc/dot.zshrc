autoload -Uz compinit promptinit
compinit
promptinit

prompt walters

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
