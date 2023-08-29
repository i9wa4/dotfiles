export LC_ALL=C.UTF-8
export XDG_CONFIG_HOME="${HOME}"/.config

# Neovim
export NVIM_APPNAME1=nvim-default
export NVIM_APPNAME2=nvim-minimal
export NVIM_APPNAME="${NVIM_APPNAME1}"

# Deno
export DENO_TLS_CA_STORE="system"
export DENO_INSTALL="${HOME}"/.deno
export PATH="${DENO_INSTALL}"/bin:"${PATH}"

# Go
export PATH="${HOME}"/go/bin:"${PATH}"

# Python
export PY_VER_MINOR=3.11
export PY_VER_PATCH=3.11.5
export PY_VENV_MYENV="${HOME}"/venv/myenv
