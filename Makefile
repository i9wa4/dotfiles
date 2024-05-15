MAKEFLAGS += --warn-undefined-variables
SHELL := /usr/bin/env bash
.SHELLFLAGS := -euo pipefail -o posix -c
.DEFAULT_GOAL := help


# variables
MF_WIN_UTIL_DIR := /mnt/c/work/util

# all targets are phony
.PHONY: $(shell egrep -o ^[a-zA-Z_-]+: $(MAKEFILE_LIST) | sed 's/://')


ubuntu-minimal: init-zshrc init-copy link apt git vim-init-ubuntu vim-build-ubuntu go-package
	chsh -s "$$(which zsh)"

wsl2: ubuntu-minimal ## task for WSL2 Ubuntu
	win-copy \
	echo "cd" >> "$${HOME}"/.zshrc
	echo "Restart WSL"

ubuntu: ubuntu-minimal ## task for Ubuntu
	docker-init-ubuntu docker-systemd-ubuntu \
	desktop-ubuntu font-ubuntu

mac: init-zshrc init-copy link brew git vim-init-mac go-package ## task for Mac


init-zshrc:
	# Zsh
	echo "if test -f "$${HOME}"/dotfiles/dot.zshrc; then . "$${HOME}"/dotfiles/dot.zshrc; fi" >> "$${HOME}"/.zshrc
	echo "cd" >> "$${HOME}"/.zshrc
	echo "if test -f "$${HOME}"/dotfiles/dot.zshenv; then . "$${HOME}"/dotfiles/dot.zshenv; fi" >> "$${HOME}"/.zshenv

init-copy:
	# Alacritty
	cp -rf "$${HOME}"/dotfiles/dot.config/alacritty/alacritty_local_sample.toml "$${HOME}"/alacritty_local.toml

link: ## make symbolic links
	# dotfiles
	ln -fs "$${HOME}"/dotfiles/dot.gitignore "$${HOME}"/.gitignore
	# Vim (symbolic link)
	if test -d "$${HOME}"/.vim; then unlink "$${HOME}"/.vim; fi
	ln -fs "$${HOME}"/dotfiles/dot.vim "$${HOME}"/.vim
	# $XDG_CONFIG_HOME
	. "${HOME}"/dotfiles/dot.zshenv \
	&& mkdir -p "$${XDG_CONFIG_HOME}" \
	&& ln -fs "$${HOME}"/dotfiles/dot.config/"$${NVIM_APPNAME1}"    "$${XDG_CONFIG_HOME}" \
	&& ln -fs "$${HOME}"/dotfiles/dot.config/"$${NVIM_APPNAME2}"    "$${XDG_CONFIG_HOME}" \
	&& ln -fs "$${HOME}"/dotfiles/dot.config/alacritty              "$${XDG_CONFIG_HOME}" \
	&& ln -fs "$${HOME}"/dotfiles/dot.config/efm-langserver         "$${XDG_CONFIG_HOME}" \
	&& ln -fs "$${HOME}"/dotfiles/dot.config/tmux                   "$${XDG_CONFIG_HOME}" \
	&& ln -fs "$${HOME}"/dotfiles/dot.config/zeno                   "$${XDG_CONFIG_HOME}"
	# && cp -rf "$${HOME}"/dotfiles/dot.config/jupyter "$${XDG_CONFIG_HOME}" \
	# && cp -rf "${HOME}"/dotfiles/dot.config/jupyter/* "$${PY_VENV_MYENV}"/share/jupyter

win-copy: ## copy config files for Windows
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

apt:
	sudo add-apt-repository -y ppa:git-core/ppa
	sudo add-apt-repository -y ppa:aslatter/ppa
	sudo sed -i -e "s/^# deb-src/deb-src/" /etc/apt/sources.list
	sudo apt update
	sudo apt upgrade -y
	sudo apt install -y \
	  alacritty \
	  bc \
	  fzf \
	  nkf \
	  ripgrep \
	  shellcheck \
	  tmux \
	  unzip \
	  vim \
	  xsel \
	  zip \
	  zsh

brew:
	# https://brew.sh/
	/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	brew -v
	brew update
	brew upgrade
	brew install \
	  fzf \
	  git \
	  hadolint \
	  nvim \
	  ripgrep \
	  shellcheck \
	  tmux \
	  vim \
	  wget
	brew install --cask google-cloud-sdk
	# https://namileriblog.com/mac/rust_alacritty/
	brew install --cask alacritty

git:
	# git config --global alias.lo "log --graph --all --format='%C(cyan dim)(%ad) %C(white dim)%h %C(green)<%an> %Creset%s %C(bold yellow)%d' --date=short"
	git config --global commit.verbose true
	git config --global core.autocrlf input
	git config --global core.editor vim
	git config --global core.excludesfile ~/.gitignore
	git config --global core.pager "LESSCHARSET=utf-8 less"
	git config --global core.quotepath false
	git config --global credential.helper store
	git config --global diff.algorithm histogram
	git config --global diff.compactionHeuristic true
	git config --global diff.tool vimdiff
	git config --global difftool.prompt false
	git config --global difftool.vimdiff.path vim
	git config --global grep.lineNumber true
	git config --global http.sslVerify false
	git config --global init.defaultBranch main
	git config --global merge.conflictstyle diff3
	git config --global merge.tool vimdiff
	git config --global mergetool.prompt false
	git config --global mergetool.vimdiff.path vim
	git config --global push.default current

vim-init-ubuntu: ## initialize for building Vim
	# sudo sed -i -e "s/^# deb-src/deb-src/" /etc/apt/sources.list
	# sudo apt update
	sudo apt build-dep -y vim
	cd /usr/local/src \
	&& if [ ! -d ./vim ]; then sudo git clone https://github.com/vim/vim.git; fi
	# Deno
	if [ -z "$$(which deno)" ]; then curl -fsSL https://deno.land/install.sh | bash; fi
	# SKK
	mkdir -p "$${HOME}"/.skk
	cd "$${HOME}"/.skk \
	&& wget http://openlab.jp/skk/dic/SKK-JISYO.L.gz \
	&& gzip -d SKK-JISYO.L.gz \
	&& wget http://openlab.jp/skk/dic/SKK-JISYO.jinmei.gz \
	&& gzip -d SKK-JISYO.jinmei.gz
	# Go
	sudo add-apt-repository -y ppa:longsleep/golang-backports
	sudo apt update
	sudo apt install -y golang-go

vim-init-mac: ## initialize for Vim in Mac
	# Deno
	brew install deno
	# SKK
	mkdir -p "$${HOME}"/.skk
	cd "$${HOME}"/.skk \
	&& wget http://openlab.jp/skk/dic/SKK-JISYO.L.gz \
	&& gzip -d SKK-JISYO.L.gz \
	&& wget http://openlab.jp/skk/dic/SKK-JISYO.jinmei.gz \
	&& gzip -d SKK-JISYO.jinmei.gz
	# Go
	brew install go

vim-build-ubuntu: ## build Vim
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
	  --with-x \
	&& sudo make \
	&& sudo make install \
	&& hash -r

nvim-init-ubuntu: ## initialize for building Neovim
	# https://github.com/neovim/neovim/wiki/Building-Neovim
	# sudo apt update
	sudo apt install -y \
	  autoconf \
	  automake \
	  cmake \
	  cmake \
	  curl \
	  doxygen \
	  g++ \
	  gcc \
	  gettext \
	  libtool \
	  libtool-bin \
	  ninja-build \
	  pkg-config \
	  unzip
	cd /usr/local/src \
	&& if [ ! -d ./neovim ]; then sudo git clone https://github.com/neovim/neovim.git; fi

nvim-build-ubuntu: ## build Neovim
	cd /usr/local/src/neovim \
	&& sudo git switch master \
	&& sudo git fetch \
	&& sudo git merge \
	&& sudo make distclean \
	&& sudo make CMAKE_BUILD_TYPE=RelWithDebInfo \
	    BUNDLED_CMAKE_FLAG='-DUSE_BUNDLED_TS_PARSERS=ON' \
	&& sudo make install

docker-init-ubuntu: ## install Docker
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

docker-hadolint-ubuntu: ## install hadolint
	sudo curl -L https://github.com/hadolint/hadolint/releases/download/v2.12.0/hadolint-Linux-x86_64 -o /usr/local/bin/hadolint
	sudo chmod 755 /usr/local/bin/hadolint

docker-systemd-ubuntu: ## enable autostart for docker
	sudo systemctl daemon-reload
	sudo systemctl start docker
	sudo systemctl enable docker

# docker-trivy-ubuntu: ## install trivy
# 	# https://aquasecurity.github.io/trivy/v0.45/getting-started/installation/
# 	sudo apt-get install wget apt-transport-https gnupg lsb-release
# 	wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
# 	echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb "$$(lsb_release -sc) main"" | sudo tee -a /etc/apt/sources.list.d/trivy.list
# 	sudo apt-get update
# 	sudo apt-get install trivy

go-package: ## install go packages
	go install github.com/rhysd/vim-startuptime@latest
	# $ vim-startuptime -vimpath nvim -count 100
	# $ vim-startuptime -vimpath vim -count 100
	go install github.com/mattn/efm-langserver@latest

jekyll-init-ubuntu: ## install Jekyll
	# https://maeda577.github.io/2019/11/04/new-jekyll.html
	# https://github.com/github/pages-gem
	sudo apt update
	sudo apt upgrade -y
	sudo apt install -y ruby-full build-essential zlib1g-dev
	. "${HOME}"/dotfiles/dot.zshenv \
	&& gem install jekyll bundler

# nodejs-init-ubnutu: ## install Node.js
# 	# Node.js/npm
# 	# https://github.com/nodesource/distributions/blob/master/README.md#using-ubuntu
# 	curl -fsSL https://deb.nodesource.com/setup_21.x | sudo -E bash - &&\
# 	sudo apt-get install -y nodejs
# 	sudo npm install -g @mermaid-js/mermaid-cli
# 	# https://github.com/mermaid-js/mermaid-cli/issues/595
# 	node /usr/lib/node_modules/@mermaid-js/mermaid-cli/node_modules/puppeteer/install.js

# py-init-ubuntu: ## initialize for building CPython
# 	# https://devguide.python.org/getting-started/setup-building/#build-dependencies
# 	# sudo sed -i -e "s/^# deb-src/deb-src/" /etc/apt/sources.list
# 	# sudo apt update
# 	sudo apt build-dep -y python3
# 	sudo apt install -y \
# 	  build-essential gdb lcov pkg-config \
# 	  libbz2-dev libffi-dev libgdbm-dev libgdbm-compat-dev liblzma-dev \
# 	  libncurses5-dev libreadline6-dev libsqlite3-dev libssl-dev \
# 	  lzma lzma-dev tk-dev uuid-dev zlib1g-dev
# 	cd /usr/local/src \
# 	&& if [ ! -d ./cpython ]; then sudo git clone https://github.com/python/cpython.git; fi

# py-build-ubuntu: ## build CPython
# 	. "${HOME}"/dotfiles/dot.zshenv \
# 	&& cd /usr/local/src/cpython \
# 	&& sudo git checkout . \
# 	&& sudo git switch main \
# 	&& sudo git fetch \
# 	&& sudo git merge \
# 	&& sudo git checkout refs/tags/v"$${PY_VER_PATCH}" \
# 	&& sudo ./configure --with-pydebug \
# 	&& sudo make \
# 	&& sudo make altinstall \
# 	&& python"$${PY_VER_MINOR}" --version \
# 	&& sudo python -m pip config --global set global.require-virtualenv true

# py-vmu: ## update venv named myenv
# 	. "${HOME}"/dotfiles/dot.zshenv \
# 	&& if [ -d "$${PY_VENV_MYENV}" ]; then \
# 	  python"$${PY_VER_MINOR}" -m venv "$${PY_VENV_MYENV}" --clear; \
# 	else \
# 	  python"$${PY_VER_MINOR}" -m venv "$${PY_VENV_MYENV}"; \
# 	fi \
# 	&& . "$${PY_VENV_MYENV}"/bin/activate \
# 	&& python"$${PY_VER_MINOR}" -m pip config --site set global.trusted-host "pypi.org pypi.python.org files.pythonhosted.org" \
# 	&& python"$${PY_VER_MINOR}" -m pip install --upgrade pip setuptools wheel \
# 	&& python"$${PY_VER_MINOR}" -m pip install -r "$${HOME}"/dotfiles/etc/py_venv_myenv_requirements.txt \
# 	&& python"$${PY_VER_MINOR}" -m pip check \
# 	&& python --version \
# 	&& deactivate

# py-tag: ## show cpython tags
# 	. "${HOME}"/dotfiles/dot.zshenv \
# 	&& sudo git -C /usr/local/src/cpython fetch \
# 	&& sudo git -C /usr/local/src/cpython tag | grep v"$${PY_VER_MINOR}"

pyenv-init-mac: ## initialize for pyenv in Mac
	# https://github.com/pyenv/pyenv/wiki#suggested-build-environment
	brew update
	brew install pyenv
	brew install openssl readline sqlite3 xz zlib tcl-tk
	# https://github.com/pyenv/pyenv?tab=readme-ov-file#set-up-your-shell-environment-for-pyenv
	echo 'eval "$$(pyenv init --path)"' >> ~/.zshrc

pyenv-init-ubuntu: ## initialize for pyenv in Mac
	# https://github.com/pyenv/pyenv/wiki#suggested-build-environment
	curl https://pyenv.run | bash
	sudo apt update
	sudo apt install -y \
	  build-essential libssl-dev zlib1g-dev \
	  libbz2-dev libreadline-dev libsqlite3-dev curl git \
	  libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
	# https://github.com/pyenv/pyenv?tab=readme-ov-file#set-up-your-shell-environment-for-pyenv
	echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
	echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
	echo 'eval "$$(pyenv init --path)"' >> ~/.zshrc

pyenv-build: ## build CPython
	. "${HOME}"/dotfiles/dot.zshenv \
	&& pyenv -v \
	&& pyenv install --list \
	&& pyenv install "$${PY_VER_MINOR}" \
	&& pyenv versions \
	&& pyenv global  "$${PY_VER_MINOR}" \
	&& python -m pip config --site set global.require-virtualenv true

pyenv-vmu: ## update venv named myenv
	. "${HOME}"/dotfiles/dot.zshenv \
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

pyenv-list: ## show available versions
	pyenv install --list | grep '^\s*'"$${PY_VER_MINOR}"


# r-init-ubuntu: ## install R
# 	# sudo apt update
# 	sudo apt install -y --no-install-recommends \
# 	  software-properties-common dirmngr
# 	wget -qO- \
# 	  https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc \
# 	  | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
# 	sudo add-apt-repository -y \
# 	  "deb https://cloud.r-project.org/bin/linux/ubuntu ""$$(lsb_release -cs)""-cran40/"
# 	sudo apt install -y --no-install-recommends r-base
# 	sudo apt install -y libcurl4-openssl-dev libxml2-dev libblas-dev liblapack-dev libavfilter-dev
# 	sudo apt install -y pandoc
# 	sudo R -e "install.packages('rmarkdown', dependencies=TRUE)"
# 	sudo R -e "install.packages('IRkernel', dependencies=TRUE)"
# 	# sudo R -e "install.packages('DiagrammeR', dependencies=TRUE)"
# 	# sudo R -e "install.packages('devtools', dependencies=TRUE)"
# 	. "${HOME}"/dotfiles/dot.zshenv \
# 	&& . "$${PY_VENV_MYENV}"/bin/activate \
# 	&& R -e "IRkernel::installspec()"

# rust-init-ubuntu: ## install Rust
# 	sudo apt install -y cargo
# 	cargo install tokei

desktop-ubuntu:
	# Settings --> Accessibility --> Large Text
	# https://zenn.dev/wsuzume/articles/26b26106c3925e
	sudo apt install -y openssh-server
	sudo systemctl daemon-reload
	sudo systemctl enable ssh.service
	sudo systemctl start ssh.service

font-ubuntu:
	# https://myrica.estable.jp/
	cd \
	&& curl -OL https://github.com/tomokuni/Myrica/raw/master/product/MyricaM.zip \
	&& unzip -d MyricaM MyricaM.zip \
	&& sudo cp MyricaM/MyricaM.TTC /usr/share/fonts/truetype/ \
	&& fc-cache -fv \
	&& rm -f MyricaM.zip \
	&& rm -rf MyricaM

help: ## Print this help
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
