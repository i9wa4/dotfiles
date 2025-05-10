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

# Homebrew
export DYLD_LIBRARY_PATH=/opt/homebrew/lib
export PATH=/opt/homebrew/bin:"${PATH}"

# AWS
# export AWS_DEFAULT_PROFILE=
export AWS_PROFILE=

# act
export PATH="${HOME}"/ghq/github.com/nektos/act/dist/local:"${PATH}"

# Deno
# export DENO_TLS_CA_STORE='system'
export DENO_INSTALL="${HOME}"/.deno
export PATH="${DENO_INSTALL}"/bin:"${PATH}"
# export DENO_NO_UPDATE_CHECK=1
export DENO_VER_PATCH=2.3.1

# fzf
export FZF_DEFAULT_OPTS='--reverse'

# Go
export PATH="${HOME}"/go/bin:"${PATH}"

# Java
# https://docs.aws.amazon.com/corretto/latest/corretto-24-ug/macos-install.html
export JAVA_HOME=/Library/Java/JavaVirtualMachines/amazon-corretto-24.jdk/Contents/Home

# Neovim
export NVIM_APPNAME=nvim

# pyenv
# export PYENV_ROOT="${HOME}"/.pyenv
# [ -d "${PYENV_ROOT}"/bin ] && export PATH="${PYENV_ROOT}"/bin:"${PATH}"
# # https://github.com/pyenv/pyenv?tab=readme-ov-file#set-up-your-shell-environment-for-pyenv
# [ -n "$(command -v pyenv)" ] && eval "$(pyenv init --path)"

# Python
export JP_LSP_VIRTUAL_DIR="${HOME}"/.cache/.virtual_documents
export JUPYTER_PLATFORM_DIRS=1
export PY_VER_MINOR=3.13

# Rust
[ -r "${HOME}"/.cargo/env ] && . "${HOME}"/.cargo/env

# tfenv
export PATH="${HOME}"/ghq/github.com/tfutils/tfenv/bin:"${PATH}"
export TF_VER_MINOR=1.11

# Volta
export VOLTA_HOME="${HOME}"/.volta
export PATH="${VOLTA_HOME}"/bin:"${PATH}"

# zeno.zsh
# export ZENO_DISABLE_TMUX_SESSION_RENAME=1

# Common
export VISUAL=vim
export PATH="${HOME}"/.local/bin:"${PATH}"
export PATH="${PATH}":/snap/bin
export XDG_CACHE_HOME="${HOME}"/.cache
export XDG_CONFIG_HOME="${HOME}"/.config

if locale -a | grep -q "en_US.UTF-8"; then
  export LC_ALL=en_US.UTF-8
else
  export LC_ALL=C.UTF-8
fi
