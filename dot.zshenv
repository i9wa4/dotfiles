# loaded /etc/zsh/zshenv

# https://zenn.dev/enchan1207/articles/7b9d7d397b7d0d
if [ -n "${ZSH_VERSION:-}" ]; then
  typeset -U path PATH

  if [ "$(uname -s)" = "Darwin" ]; then
    setopt no_global_rcs
    if [ -x /usr/libexec/path_helper ]; then
        eval `/usr/libexec/path_helper -s`
    fi
  fi
fi

# Common
export EDITOR=vim
export PATH="${PATH}":/snap/bin
export TZ="Asia/Tokyo"
export VISUAL=vim
export XDG_CACHE_HOME="${HOME}"/.cache
export XDG_CONFIG_HOME="${HOME}"/.config

if locale -a | grep -q "en_US.UTF-8"; then
  export LC_ALL=en_US.UTF-8
else
  export LC_ALL=C.UTF-8
fi

# AWS
export AWS_DEFAULT_PROFILE=
export AWS_PROFILE=

# Claude
export CLAUDE_CONFIG_DIR="${HOME}"/ghq/github.com/i9wa4/dotfiles/dot.config/claude

# fzf
export FZF_DEFAULT_OPTS="
  --reverse
  --bind 'ctrl-y:accept'
"

# gtr (git-worktree-runner)
export PATH="${PATH}":"${HOME}"/ghq/github.com/coderabbitai/git-worktree-runner/bin

# Homebrew
export DYLD_LIBRARY_PATH=/opt/homebrew/lib
export PATH=/opt/homebrew/bin:"${PATH}"

# mise
# export PATH="${PATH}":"${HOME}"/.local/share/mise/shims

# Neovim
export NVIM_APPNAME=nvim

# zeno.zsh
export ZENO_DISABLE_EXECUTE_CACHE_COMMAND=1

# First Priority Paths
export PATH="${HOME}"/.local/bin:"${PATH}"
# dotfiles bin directory (hardcoded path for Nix compatibility)
export PATH="${HOME}"/ghq/github.com/i9wa4/dotfiles/bin:"${PATH}"
