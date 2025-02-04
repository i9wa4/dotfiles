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
export AWS_DEFAULT_PROFILE=
export AWS_PROFILE=

# act
export PATH="${HOME}"/ghq/github.com/nektos/act/dist/local:"${PATH}"

# Deno
export DENO_TLS_CA_STORE='system'
export DENO_INSTALL="${HOME}"/.deno
export PATH="${DENO_INSTALL}"/bin:"${PATH}"
export DENO_VER_PATCH=2.1.7

# fzf
export FZF_DEFAULT_OPTS='--reverse'

# Go
export PATH="${HOME}"/go/bin:"${PATH}"

# pyenv
export PYENV_ROOT="${HOME}"/.pyenv
[ -d "${PYENV_ROOT}"/bin ] && export PATH="${PYENV_ROOT}"/bin:"${PATH}"
# https://github.com/pyenv/pyenv?tab=readme-ov-file#set-up-your-shell-environment-for-pyenv
[ -n "$(command -v pyenv)" ] && eval "$(pyenv init --path)"

# Python
export JP_LSP_VIRTUAL_DIR="${HOME}"/.cache/.virtual_documents
export JUPYTER_PLATFORM_DIRS=1
export PY_VER_MINOR=3.12
export PY_VENV_MYENV="${HOME}"/.venv/myenv"${PY_VER_MINOR}"
export PY_VENV_DBTENV="${HOME}"/.venv/dbtenv"${PY_VER_MINOR}"

# Rust
if [ -r "${HOME}"/.cargo/env ]; then . "${HOME}"/.cargo/env; fi

# tfenv
export PATH="${HOME}"/ghq/github.com/tfutils/tfenv/bin:"${PATH}"
export TF_VER_MINOR=1.9

# Volta
export VOLTA_HOME="${HOME}"/.volta
export PATH="${VOLTA_HOME}"/bin:"${PATH}"

# zeno.zsh
export ZENO_DISABLE_TMUX_SESSION_RENAME=1

# Common
export EDITOR=vim
export VISUAL=vim
export XDG_CONFIG_HOME="${HOME}"/.config
export PATH="${HOME}"/.local/bin:"${PATH}"
export PATH=/snap/bin:"${PATH}"
export GHQ_LIST_LOCAL_PATH="${HOME}"/ghq-list-local.txt

if locale -a | grep -q "en_US.UTF-8"; then
  export LC_ALL=en_US.UTF-8
else
  export LC_ALL=C.UTF-8
fi
