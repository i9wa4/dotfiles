# Vim
export EDITOR=vim
export VISUAL=vim

# Neovim
export NVIM_APPNAME1=nvim
export NVIM_APPNAME2=nvim-minimal
export NVIM_APPNAME="${NVIM_APPNAME1}"

# Deno
export DENO_TLS_CA_STORE="system"
export DENO_INSTALL="${HOME}"/.deno
export PATH="${DENO_INSTALL}"/bin:"${PATH}"

# Go
export PATH="${HOME}"/go/bin:"${PATH}"

# Python
export PY_VER_MINOR=3.12
export PY_VENV_MYENV="${HOME}"/venv/myenv"${PY_VER_MINOR}"
export JP_LSP_VIRTUAL_DIR="${HOME}"/.cache/.virtual_documents
export JUPYTER_PLATFORM_DIRS=1

# Rust
export PATH="${HOME}"/.cargo/env:"${PATH}"

# pyenv
export PYENV_ROOT="${HOME}"/.pyenv
[[ -d "${PYENV_ROOT}"/bin ]] && export PATH="${PYENV_ROOT}"/bin:"${PATH}"

# tfenv
export PATH="${HOME}"/src/github.com/tfutils/tfenv/bin:"${PATH}"
export TFENV_TF_VER_MINOR=1.9
export TFENV_TF_VER_PATCH="${TFENV_TF_VER_MINOR}".0

# Volta
export VOLTA_HOME="${HOME}"/.volta
export PATH="${VOLTA_HOME}"/.volta/bin:"${PATH}"

# AWS
export AWS_DEFAULT_PROFILE=

# Homebrew
export PATH=/opt/homebrew/bin:"${PATH}"
export DYLD_LIBRARY_PATH=/opt/homebrew/lib

# Common
export LC_ALL=C.UTF-8
export XDG_CONFIG_HOME="${HOME}"/.config
export PATH="${HOME}"/bin:"${PATH}"
