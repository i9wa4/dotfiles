MAKEFLAGS += --warn-undefined-variables
SHELL := /usr/bin/env bash
.SHELLFLAGS := -euo pipefail -o posix -c
.DEFAULT_GOAL := help


# variables
MF_WIN_UTIL_DIR := /mnt/c/work/util

# all targets are phony
.PHONY: $(shell egrep -o ^[a-zA-Z_-]+: $(MAKEFILE_LIST) | sed 's/://')


ubuntu-minimal: init-zshrc init-copy link package-ubuntu git vim-init
	chsh -s "$$(which zsh)"

ubuntu: ubuntu-minimal  ## task for Ubuntu
	docker-init-ubuntu docker-systemd-ubuntu \
	go-package

ubuntu-server: ubuntu  ## task for Ubuntu Server
	package-ubuntu-server

ubuntu-desktop:  ## task for Ubuntu Desktop
	package-ubuntu-desktop

wsl2: ubuntu-minimal  ## task for WSL2 Ubuntu
	copy-win \
	echo "Restart WSL"

mac: init-zshrc init-copy link package-mac package-homebrew go-package git vim-init  ## task for Mac


init-zshrc:
	# Zsh
	echo "if test -f "$${HOME}"/dotfiles/dot.zshrc; then . "$${HOME}"/dotfiles/dot.zshrc; fi" >> "$${HOME}"/.zshrc
	echo "cd" >> "$${HOME}"/.zshrc
	echo "if test -f "$${HOME}"/dotfiles/dot.zshenv; then . "$${HOME}"/dotfiles/dot.zshenv; fi" >> "$${HOME}"/.zshenv

init-copy:
	# Alacritty
	cp -rf "$${HOME}"/dotfiles/dot.config/alacritty/alacritty_local_sample.toml "$${HOME}"/alacritty_local.toml

link:  ## make symbolic links
	# dotfiles
	ln -fs "$${HOME}"/dotfiles/dot.gitignore "$${HOME}"/.gitignore
	# Vim (symbolic link)
	if test -d "$${HOME}"/.vim; then unlink "$${HOME}"/.vim; fi
	ln -fs "$${HOME}"/dotfiles/dot.vim "$${HOME}"/.vim
	# XDG_CONFIG_HOME
	. "$${HOME}"/dotfiles/dot.zshenv \
	&& mkdir -p "$${XDG_CONFIG_HOME}" \
	&& ln -fs "$${HOME}"/dotfiles/dot.config/"$${NVIM_APPNAME1}"    "$${XDG_CONFIG_HOME}" \
	&& ln -fs "$${HOME}"/dotfiles/dot.config/"$${NVIM_APPNAME2}"    "$${XDG_CONFIG_HOME}" \
	&& ln -fs "$${HOME}"/dotfiles/dot.config/alacritty              "$${XDG_CONFIG_HOME}" \
	&& ln -fs "$${HOME}"/dotfiles/dot.config/efm-langserver         "$${XDG_CONFIG_HOME}" \
	&& ln -fs "$${HOME}"/dotfiles/dot.config/tmux                   "$${XDG_CONFIG_HOME}" \
	&& ln -fs "$${HOME}"/dotfiles/dot.config/zeno                   "$${XDG_CONFIG_HOME}"
	# && cp -rf "$${HOME}"/dotfiles/dot.config/jupyter "$${XDG_CONFIG_HOME}" \
	# && cp -rf "$${HOME}"/dotfiles/dot.config/jupyter/* "$${PY_VENV_MYENV}"/share/jupyter

copy-win:  ## copy config files for Windows
	# WSL2
	sudo cp -f "$${HOME}"/dotfiles/etc/wsl.conf /etc/wsl.conf
	# Windows symbolic link
	mkdir -p /mnt/c/work
	# Windows copy
	rm -rf $(MF_WIN_UTIL_DIR)
	mkdir -p $(MF_WIN_UTIL_DIR)
	cp -f "$${HOME}"/dotfiles/bin/windows/my_copy.bat $(MF_WIN_UTIL_DIR)
	cp -rf "$${HOME}"/dotfiles/bin $(MF_WIN_UTIL_DIR)
	cp -rf "$${HOME}"/dotfiles/dot.config $(MF_WIN_UTIL_DIR)
	cp -rf "$${HOME}"/dotfiles/dot.vim $(MF_WIN_UTIL_DIR)
	cp -rf "$${HOME}"/dotfiles/dot.vscode $(MF_WIN_UTIL_DIR)
	cp -rf "$${HOME}"/dotfiles/etc $(MF_WIN_UTIL_DIR)

package-ubuntu:
	sudo add-apt-repository -y ppa:git-core/ppa
	sudo apt update
	sudo apt upgrade -y
	sudo apt install -y \
	  bc \
	  curl \
	  fzf \
	  jq \
	  nkf \
	  ripgrep \
	  shellcheck \
	  ssh \
	  tmux \
	  unzip \
	  vim \
	  xsel \
	  zip \
	  zsh
	# Deno
	if [ -z "$$(which deno)" ]; then curl -fsSL https://deno.land/install.sh | bash; fi
	# Go
	sudo add-apt-repository -y ppa:longsleep/golang-backports
	sudo apt update
	sudo apt install -y golang-go
	# Vim build dependencies
	# Ubuntu-22.04
	sudo sed -i 's/^# deb-src/deb-src/' /etc/apt/sources.list
	sudo apt update
	sudo apt build-dep -y vim
	# https://github.com/neovim/neovim/blob/master/BUILD.md
	sudo apt install -y \
	  ninja-build gettext cmake unzip curl build-essential
	# https://github.com/pyenv/pyenv/wiki#suggested-build-environment
	curl https://pyenv.run | bash
	sudo apt install -y \
	  build-essential libssl-dev zlib1g-dev \
	  libbz2-dev libreadline-dev libsqlite3-dev curl git \
	  libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
	# Zsh
	bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
	. "${HOME}"/.zshrc \
	&& zinit self-update

package-ubuntu-desktop:
	sudo add-apt-repository -y ppa:aslatter/ppa
	sudo apt update
	sudo apt install -y alacritty
	# https://myrica.estable.jp/
	cd \
	&& curl -OL https://github.com/tomokuni/Myrica/raw/master/product/MyricaM.zip \
	&& unzip -d MyricaM MyricaM.zip \
	&& sudo cp MyricaM/MyricaM.TTC /usr/share/fonts/truetype/ \
	&& fc-cache -fv \
	&& rm -f MyricaM.zip \
	&& rm -rf MyricaM

package-ubuntu-server:
	# Settings --> Accessibility --> Large Text
	# https://zenn.dev/wsuzume/articles/26b26106c3925e
	sudo apt install -y openssh-server
	sudo systemctl daemon-reload
	sudo systemctl enable ssh.service
	sudo systemctl start ssh.service

package-homebrew:
	brew -v
	brew update
	brew upgrade
	brew install \
	  fzf \
	  git \
	  hadolint \
	  jq \
	  nvim \
	  ripgrep \
	  shellcheck \
	  tmux \
	  vim \
	  wget \
	  zsh
	# Deno
	brew install deno
	# Go
	brew install go
	# https://github.com/neovim/neovim/blob/master/BUILD.md
	brew install ninja cmake gettext curl
	# https://github.com/pyenv/pyenv/wiki#suggested-build-environment
	brew install pyenv
	brew install openssl readline sqlite3 xz zlib tcl-tk
	# https://developer.hashicorp.com/terraform/install
	brew tap hashicorp/tap
	brew install hashicorp/tap/terraform

package-mac:
	# https://brew.sh/
	/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	brew install --cask google-cloud-sdk
	# https://namileriblog.com/mac/rust_alacritty/
	brew install --cask alacritty
	# https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
	cd "${HOME}" \
	&& curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg" \
	&& sudo installer -pkg AWSCLIV2.pkg -target /
	# Zsh
	bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
	. "${HOME}"/.zshrc \
	&& zinit self-update

git:
	git config --global color.ui auto
	git config --global commit.verbose true
	git config --global core.autocrlf input
	git config --global core.editor vim
	git config --global core.excludesfile ~/.gitignore
	git config --global core.ignorecase false
	git config --global core.pager "LESSCHARSET=utf-8 less"
	git config --global core.quotepath false
	git config --global core.safecrlf true
	git config --global credential.helper store
	git config --global diff.algorithm histogram
	git config --global diff.compactionHeuristic true
	git config --global diff.tool vimdiff
	git config --global difftool.prompt false
	git config --global difftool.vimdiff.path vim
	git config --global ghq.root ~/src
	git config --global grep.lineNumber true
	git config --global http.sslVerify false
	git config --global init.defaultBranch main
	git config --global merge.conflictstyle diff3
	git config --global merge.tool vimdiff
	git config --global mergetool.prompt false
	git config --global mergetool.vimdiff.path vim
	git config --global push.default current

vim-init:  ## initialize for building Vim
	sudo mkdir -p /usr/local/src \
	&& cd /usr/local/src \
	&& if [ ! -d ./vim ]; then sudo git clone https://github.com/vim/vim.git; fi

vim-build:  ## build Vim
	# sudo make clean
	cd /usr/local/src/vim \
	&& sudo git switch master \
	&& sudo git fetch \
	&& sudo git merge \
	&& cd ./src \
	&& sudo ./configure \
	  --disable-gui \
	  --enable-fail-if-missing \
	  --enable-python3interp=dynamic \
	  --prefix=/usr/local \
	  --with-features=huge \
	&& sudo make \
	&& sudo make install \
	&& hash -r

nvim-init:  ## initialize for building Neovim
	sudo mkdir -p /usr/local/src \
	&& cd /usr/local/src \
	&& if [ ! -d ./neovim ]; then sudo git clone https://github.com/neovim/neovim.git; fi

nvim-build:  ## build Neovim
	cd /usr/local/src/neovim \
	&& sudo git switch master \
	&& sudo git fetch \
	&& sudo git merge \
	&& sudo make distclean \
	&& sudo make CMAKE_BUILD_TYPE=RelWithDebInfo \
	  BUNDLED_CMAKE_FLAG='-DUSE_BUNDLED_TS_PARSERS=ON' \
	&& sudo make install \
	&& hash -r

awscli-init-ubuntu:
	# https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
	cd "${HOME}" \
	&& curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
	&& unzip awscliv2.zip \
	&& sudo ./aws/install \
	&& rm awscliv2.zip


docker-init-ubuntu:  ## install Docker
	# https://docs.docker.com/engine/install/ubuntu
	# Uninstall old versions
	for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove "$${pkg}"; done
	# Add Docker's official GPG key
	sudo apt-get update
	sudo apt-get install -y ca-certificates curl gnupg
	sudo install -m 0755 -d /etc/apt/keyrings
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
	sudo chmod a+r /etc/apt/keyrings/docker.gpg
	# Add the repository to Apt sources
	echo \
	  "deb [arch="$$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
	  "$$(. /etc/os-release && echo "$${VERSION_CODENAME}")" stable" | \
	  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt-get update
	# Install the Docker packages
	sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
	# https://docs.docker.com/engine/install/linux-postinstall/
	# If you're running Linux in a virtual machine, it may be necessary to restart the virtual machine for changes to take effect.
	# sudo groupadd docker
	sudo usermod -aG docker "$${USER}"
	# hadolint
	sudo curl -L https://github.com/hadolint/hadolint/releases/download/v2.12.0/hadolint-Linux-x86_64 -o /usr/local/bin/hadolint
	sudo chmod 755 /usr/local/bin/hadolint
	# Trivy
	# https://aquasecurity.github.io/trivy/v0.45/getting-started/installation/
	sudo apt-get install wget apt-transport-https gnupg lsb-release
	wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
	echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb "$$(lsb_release -sc) main"" | sudo tee -a /etc/apt/sources.list.d/trivy.list
	sudo apt-get update
	sudo apt-get install trivy

docker-systemd-ubuntu:  ## enable autostart for docker
	sudo systemctl daemon-reload
	sudo systemctl start docker
	sudo systemctl enable docker

go-package:  ## install go packages
	go install github.com/rhysd/vim-startuptime@latest
	# vim-startuptime -vimpath nvim -count 100
	# vim-startuptime -vimpath vim -count 100
	go install github.com/mattn/efm-langserver@latest
	# https://github.com/Songmu/ghq-handbook
	go install github.com/x-motemen/ghq@latest

pyenv-init:  ## initialize for pyenv
	# https://github.com/pyenv/pyenv?tab=readme-ov-file#set-up-your-shell-environment-for-pyenv
	echo 'export PYENV_ROOT="$${HOME}"/.pyenv' >> ~/.zshrc
	echo '[[ -d "$${PYENV_ROOT}"/bin ]] && export PATH="$${PYENV_ROOT}"/bin:"$${PATH}"' >> ~/.zshrc
	echo 'eval "$$(pyenv init --path)"' >> ~/.zshrc

pyenv-build:  ## build CPython
	. "$${HOME}"/dotfiles/dot.zshenv \
	&& pyenv -v \
	&& pyenv install --list \
	&& pyenv install "$${PY_VER_MINOR}" \
	&& pyenv versions \
	&& pyenv global  "$${PY_VER_MINOR}" \
	&& python -m pip config --site set global.require-virtualenv true

pyenv-vmu:  ## update venv named myenv
	# https://dev.classmethod.jp/articles/change-venv-python-version/
	. "$${HOME}"/dotfiles/dot.zshenv \
	&& if [ -d "$${PY_VENV_MYENV}" ]; then \
	  python -m venv "$${PY_VENV_MYENV}" --clear; \
	else \
	  python -m venv "$${PY_VENV_MYENV}"; \
	fi \
	&& . "$${PY_VENV_MYENV}"/bin/activate \
	&& python -m pip config --site set global.trusted-host "pypi.org pypi.python.org files.pythonhosted.org" \
	&& python -m pip install --upgrade pip setuptools wheel \
	&& python -m pip install -r "$${HOME}"/dotfiles/etc/py_venv_myenv_requirements.txt \
	&& python -m pip check \
	&& python --version \
	&& deactivate

pyenv-list:  ## show available versions
	. "$${HOME}"/dotfiles/dot.zshenv \
	&& echo "Available versions:" \
	&& pyenv install --list | grep '^\s*'"$${PY_VER_MINOR}" \
	&& echo "Installed versions:" \
	&& pyenv versions

terraform-init-ubuntu:
	# https://developer.hashicorp.com/terraform/install
	wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
	echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $$(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
	sudo apt update
	sudo apt install -y terraform

volta-init:  ## install Volta
	curl https://get.volta.sh | bash
	# exec "$${SHELL}" -l
	hash -r
	volta install node
	hash -r
	sudo npm install -g @mermaid-js/mermaid-cli
	# https://github.com/mermaid-js/mermaid-cli/issues/595
	# node /usr/lib/node_modules/@mermaid-js/mermaid-cli/node_modules/puppeteer/install.js

help:  ## Print this help
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
