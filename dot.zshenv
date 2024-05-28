# Common
export LC_ALL=C.UTF-8
export XDG_CONFIG_HOME="${HOME}"/.config

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

# Jekyll
export GEM_HOME="${HOME}"/gems
export PATH="${HOME}"/gems/bin:"${PATH}"

# Python
export PY_VER_MINOR=3.12
export PY_VENV_MYENV="${HOME}"/venv/myenv"${PY_VER_MINOR}"
export JP_LSP_VIRTUAL_DIR="${HOME}"/.cache/.virtual_documents
export JUPYTER_PLATFORM_DIRS=1

# Homebrew
export PATH=/opt/homebrew/bin:"${PATH}"
export DYLD_LIBRARY_PATH=/opt/homebrew/lib

# AWS
export AWS_DEFAULT_PROFILE=

# Volta
export VOLTA_HOME="${HOME}"/.volta
export PATH="${VOLTA_HOME}"/.volta/bin:"${PATH}"
