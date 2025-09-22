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
export TZ="Asia/Tokyo"
export VISUAL=vim
export XDG_CACHE_HOME="${HOME}"/.cache
export XDG_CONFIG_HOME="${HOME}"/.config

if locale -a | grep -q "en_US.UTF-8"; then
  export LC_ALL=en_US.UTF-8
else
  export LC_ALL=C.UTF-8
fi

# Homebrew
export DYLD_LIBRARY_PATH=/opt/homebrew/lib
export PATH=/opt/homebrew/bin:"${PATH}"

# AWS
export AWS_PROFILE=

# act
export PATH="${HOME}"/ghq/github.com/nektos/act/dist/local:"${PATH}"

# Claude
export CLAUDE_CONFIG_DIR="${HOME}"/ghq/github.com/i9wa4/dotfiles/dot.config/claude
# export CLAUDE_CONFIG_DIR="${XDG_CONFIG_HOME}"/claude

# Deno
# export DENO_INSTALL="${HOME}"/.proto/shims/deno
# export PATH="${DENO_INSTALL}"/bin:"${PATH}"
# export DENO_NO_UPDATE_CHECK=1
export DENO_VER_PATCH=2.4.4

# fzf
export FZF_DEFAULT_OPTS="
  --reverse
  --bind 'ctrl-y:accept'
"

# Go
export PATH="${HOME}"/go/bin:"${PATH}"

# Java
# https://docs.aws.amazon.com/corretto/latest/corretto-24-ug/macos-install.html
export JAVA_HOME=/Library/Java/JavaVirtualMachines/amazon-corretto-24.jdk/Contents/Home

# Neovim
export NVIM_APPNAME=nvim

# proto
export PROTO_HOME="${HOME}"/.proto
export PATH="${PROTO_HOME}"/shims:"${PROTO_HOME}"/bin:"${PATH}"
export PATH="${HOME}"/.proto/tools/node/22.19.0/bin:"${PATH}"

# Python
export JP_LSP_VIRTUAL_DIR="${HOME}"/.cache/.virtual_documents
export JUPYTER_PLATFORM_DIRS=1

# tfenv
export PATH="${HOME}"/ghq/github.com/tfutils/tfenv/bin:"${PATH}"
export TF_VER_MINOR=1.11

# First Priority Paths
export PATH="${PATH}":/snap/bin
export PATH="${HOME}"/.local/bin:"${PATH}"
export PATH="$(dirname "$0")/bin":"${PATH}"
