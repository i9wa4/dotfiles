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

# Git
export GIT_PS1_SHOWDIRTYSTATE=true      # *:unstaged, +:staged
export GIT_PS1_SHOWSTASHSTATE=true      # $:stashed
export GIT_PS1_SHOWUNTRACKEDFILES=true  # %:untracked
export GIT_PS1_SHOWUPSTREAM=auto        # >:ahead, <:behind

# Go
export PATH="${HOME}"/go/bin:"${PATH}"

# Jekyll
export GEM_HOME="${HOME}"/gems
export PATH="${HOME}"/gems/bin:"${PATH}"

# Python
export PY_VER_MINOR=3.11
export PY_VER_PATCH=3.11.7
export PY_VENV_MYENV="${HOME}"/venv/myenv"${PY_VER_MINOR}"
# config file path: ${XDG_CONFIG_HOME}/jupyter
export JUPYTER_PLATFORM_DIRS=1

# Rust
export PATH="${HOME}"/.cargo/bin:"${PATH}"
