export LC_ALL=C.UTF-8
export XDG_CONFIG_HOME="${HOME}"/.config

# Neovim
export NVIM_APPNAME=my_nvim

# Deno
export DENO_TLS_CA_STORE="system"
export DENO_INSTALL="${HOME}"/.deno
export PATH="${DENO_INSTALL}"/bin:"${PATH}"

# Go
export GOPATH="${HOME}"/go
export PATH="${GOPATH}"/bin:"${PATH}"

# Python
export PY_VER_MINOR=3.11
export PY_VER_PATCH=3.11.2
export PY_VENV_MYENV="${HOME}"/venv/myenv

# Jekyll
if which ruby >/dev/null && which gem >/dev/null; then
  export PATH="$(ruby -r rubygems -e 'puts Gem.user_dir')/bin:$PATH"
fi
