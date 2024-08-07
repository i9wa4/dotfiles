# https://qiita.com/eumesy/items/3bb39fc783c8d4863c5f
if [[ "$0" == *"zsh"* ]]; then setopt no_global_rcs; fi
# missing paths for macOS:
# /System/Cryptexes/App/usr/bin
# /usr/local/bin
# /var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin
# /var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin
# /var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin

# Common
export LC_ALL=C.UTF-8
export EDITOR=vim
export VISUAL=vim
export XDG_CONFIG_HOME="${HOME}"/.config

# AWS
export AWS_DEFAULT_PROFILE=

# Deno
export DENO_TLS_CA_STORE="system"
export DENO_INSTALL="${HOME}"/.deno
export PATH="${DENO_INSTALL}"/bin:"${PATH}"

# Go
export PATH="${HOME}"/go/bin:"${PATH}"

# Homebrew
export DYLD_LIBRARY_PATH=/opt/homebrew/lib
export PATH=/opt/homebrew/bin:"${PATH}"

# Neovim
export NVIM_APPNAME1=nvim
export NVIM_APPNAME2=nvim-minimal
export NVIM_APPNAME="${NVIM_APPNAME1}"

# pyenv
export PYENV_ROOT="${HOME}"/.pyenv
[[ -d "${PYENV_ROOT}"/bin ]] && export PATH="${PYENV_ROOT}"/bin:"${PATH}"

# Python
export JP_LSP_VIRTUAL_DIR="${HOME}"/.cache/.virtual_documents
export JUPYTER_PLATFORM_DIRS=1
export PY_VER_MINOR=3.12
export PY_VENV_MYENV="${HOME}"/.venv/myenv"${PY_VER_MINOR}"

# Rust
if test -f "${HOME}"/.cargo/env; then . "${HOME}"/.cargo/env; fi

# tfenv
export PATH="${HOME}"/src/github.com/tfutils/tfenv/bin:"${PATH}"
export TF_VER_MINOR=1.9

# Volta
export VOLTA_HOME="${HOME}"/.volta
export PATH="${VOLTA_HOME}"/.volta/bin:"${PATH}"

# Common $PATH
export PATH="${PATH}":/usr/local/bin
export PATH="${HOME}"/bin:"${PATH}"
