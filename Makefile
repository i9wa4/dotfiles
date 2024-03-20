MAKEFLAGS += --warn-undefined-variables
SHELL := /usr/bin/env bash
.SHELLFLAGS := -euox pipefail -o posix -c
.DEFAULT_GOAL := help


# variables
MF_WIN_UTIL_DIR := /mnt/c/work/util
MF_PY_VER_MINOR := "${PY_VER_MINOR}"
MF_PY_VER_PATCH := "${PY_VER_PATCH}"
MF_PY_VENV_MYENV := "${PY_VENV_MYENV}"
MF_NVIM_APPNAME1 := "${NVIM_APPNAME1}"
MF_NVIM_APPNAME2 := "${NVIM_APPNAME2}"


# all targets are phony
.PHONY: $(shell egrep -o ^[a-zA-Z_-]+: $(MAKEFILE_LIST) | sed 's/://')


dummy:
	@echo "MF_PY_VER_MINOR=$(MF_PY_VER_MINOR)"
	@echo "MF_PY_VER_PATCH=$(MF_PY_VER_PATCH)"
	@echo "MF_PY_VENV_MYENV=$(MF_PY_VENV_MYENV)"

ubuntu-minimal:
	setup-bashrc copy apt git vim-init vim-build

wsl2: ubuntu-minimal ## task for WSL2 Ubuntu
	win-copy \
	echo "Restart WSL"

ubuntu: ubuntu-minimal ## task for Ubuntu
	docker-init docker-systemd \
	ubuntu-desktop ubuntu-font

setup-bashrc:
	# Bash
	echo "if [ -f "$${HOME}"/dotfiles/etc/dot.bashrc ]; then . "$${HOME}"/dotfiles/etc/dot.bashrc; fi" >> "$${HOME}"/.bashrc
	echo "cd" >> "$${HOME}"/.bashrc
	echo "if [ -f "$${HOME}"/dotfiles/etc/dot.profile ]; then . "$${HOME}"/dotfiles/etc/dot.profile; fi" >> "$${HOME}"/.profile

copy: ## copy config files and make symbolic links
	# dotfiles
	. "${HOME}"/dotfiles/etc/dot.profile \
	&& cp -rf "$${HOME}"/dotfiles/dot.config/jupyter "$${XDG_CONFIG_HOME}"
	cp -rf "$${HOME}"/dotfiles/etc/home/dot.bash_profile "$${HOME}"/.bash_profile
	cp -rf "$${HOME}"/dotfiles/etc/home/dot.gitignore "$${HOME}"/.gitignore
	cp -rf "$${HOME}"/dotfiles/etc/home/dot.tmux.conf "$${HOME}"/.tmux.conf
	# Vim (symbolic link)
	rm -f "$${HOME}"/.vimrc
	rm -f "$${HOME}"/.vim
	ln -fs "$${HOME}"/dotfiles/dot.vim "$${HOME}"/.vim
	# XDG_CONFIG_HOME
	. "${HOME}"/dotfiles/etc/dot.profile \
	&& mkdir -p "$${XDG_CONFIG_HOME}" \
	&& rm -f "$${XDG_CONFIG_HOME}"/$(MF_NVIM_APPNAME1) \
	&& rm -f "$${XDG_CONFIG_HOME}"/$(MF_NVIM_APPNAME2) \
	&& rm -f "$${XDG_CONFIG_HOME}"/efm-langserver \
	&& ln -fs "$${HOME}"/dotfiles/dot.config/$(MF_NVIM_APPNAME1) "$${XDG_CONFIG_HOME}"/$(MF_NVIM_APPNAME1) \
	&& ln -fs "$${HOME}"/dotfiles/dot.config/$(MF_NVIM_APPNAME2) "$${XDG_CONFIG_HOME}"/$(MF_NVIM_APPNAME2) \
	&& ln -fs "$${HOME}"/dotfiles/dot.config/efm-langserver "$${XDG_CONFIG_HOME}"/efm-langserver

win-copy: ## copy config files for Windows
	# WSL2
	sudo cp -f "$${HOME}"/dotfiles/etc/wsl/wsl.conf /etc/wsl.conf
	# Windows symbolic link
	mkdir -p /mnt/c/work
	# rm -rf "$${HOME}"/work
	# ln -s /mnt/c/work/ "$${HOME}"/work
	# Windows copy
	rm -rf $(MF_WIN_UTIL_DIR)
	mkdir -p $(MF_WIN_UTIL_DIR)
	cp -f "$${HOME}"/dotfiles/bin/windows/my_copy.bat $(MF_WIN_UTIL_DIR)
	cp -rf "$${HOME}"/dotfiles/bin $(MF_WIN_UTIL_DIR)
	cp -rf "$${HOME}"/dotfiles/dot.config $(MF_WIN_UTIL_DIR)
	cp -rf "$${HOME}"/dotfiles/dot.vim $(MF_WIN_UTIL_DIR)
	cp -rf "$${HOME}"/dotfiles/etc $(MF_WIN_UTIL_DIR)

apt:
	sudo add-apt-repository -y ppa:git-core/ppa
	sudo sed -i -e "s/^# deb-src/deb-src/" /etc/apt/sources.list
	sudo apt update
	sudo apt upgrade -y
	sudo apt install -y \
	  bc \
	  nkf \
	  ripgrep \
	  shellcheck \
	  tmux \
	  unzip \
	  vim \
	  xsel \
	  zip

git:
	git config --global alias.lo "log --graph --all --format='%C(cyan dim)(%ad) %C(white dim)%h %C(green)<%an> %Creset%s %C(bold yellow)%d' --date=short"
	git config --global commit.verbose true
	git config --global core.autocrlf input
	git config --global core.editor vim
	git config --global core.excludesfile ~/.gitignore
	git config --global core.pager "LESSCHARSET=utf-8 less"
	git config --global core.quotepath false
	git config --global credential.helper store
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

vim-init: ## initialize for building Vim
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

vim-build: ## build Vim
	cd /usr/local/src/vim \
	&& sudo git checkout master \
	&& sudo git checkout . \
	&& sudo git fetch \
	&& sudo git merge \
	&& cd ./src \
	&& sudo make clean \
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

nvim-init: ## initialize for building Neovim
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

nvim-build: ## build Neovim
	cd /usr/local/src/neovim \
	&& sudo git checkout master \
	&& sudo git checkout . \
	&& sudo git fetch \
	&& sudo git merge \
	&& sudo make distclean \
	&& sudo make CMAKE_BUILD_TYPE=RelWithDebInfo \
	    BUNDLED_CMAKE_FLAG='-DUSE_BUNDLED_TS_PARSERS=ON' \
	&& sudo make install

anaconda-init: ## install Anaconda
	cd \
	&& wget https://repo.anaconda.com/archive/Anaconda3-2023.07-2-Linux-x86_64.sh \
	&& bash Anaconda3-2023.07-2-Linux-x86_64.sh
	. "$${HOME}"/.bashrc \
	&& conda config --append channels conda-forge \
	&& conda config --set auto_activate_base false \
	&& conda update --all \
	&& conda info -e
	# conda env create -y -f foo.yml

docker-init: ## install Docker
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

docker-hadolint: ## install hadolint
	sudo curl -L https://github.com/hadolint/hadolint/releases/download/v2.12.0/hadolint-Linux-x86_64 -o /usr/local/bin/hadolint
	sudo chmod 755 /usr/local/bin/hadolint

docker-systemd: ## enable autostart for docker
	sudo systemctl daemon-reload
	sudo systemctl start docker
	sudo systemctl enable docker

docker-trivy: ## install trivy
	# https://aquasecurity.github.io/trivy/v0.45/getting-started/installation/
	sudo apt-get install wget apt-transport-https gnupg lsb-release
	wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
	echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb "$$(lsb_release -sc) main"" | sudo tee -a /etc/apt/sources.list.d/trivy.list
	sudo apt-get update
	sudo apt-get install trivy

go-init: ## install go
	sudo add-apt-repository -y ppa:longsleep/golang-backports
	sudo apt update
	sudo apt install -y golang-go
	go install github.com/rhysd/vim-startuptime@latest
	# $ vim-startuptime -vimpath nvim -count 100
	# $ vim-startuptime -vimpath vim -count 100
	go install github.com/mattn/efm-langserver@latest

jekyll-init: ## install Jekyll
	# https://maeda577.github.io/2019/11/04/new-jekyll.html
	# https://github.com/github/pages-gem
	sudo apt update
	sudo apt upgrade -y
	sudo apt install -y ruby-full build-essential zlib1g-dev
	. "$${HOME}"/.profile \
	&& gem install jekyll bundler

nodejs-init: ## install Node.js
	# Node.js/npm
	# https://github.com/nodesource/distributions/blob/master/README.md#using-ubuntu
	curl -fsSL https://deb.nodesource.com/setup_21.x | sudo -E bash - &&\
	sudo apt-get install -y nodejs
	sudo npm install -g @mermaid-js/mermaid-cli
	# https://github.com/mermaid-js/mermaid-cli/issues/595
	node /usr/lib/node_modules/@mermaid-js/mermaid-cli/node_modules/puppeteer/install.js

psql-init: ## install PostgreSQL
	sudo apt install -y postgresql postgresql-contrib

py-init: ## initialize for building CPython
	# https://devguide.python.org/getting-started/setup-building/#build-dependencies
	# sudo sed -i -e "s/^# deb-src/deb-src/" /etc/apt/sources.list
	# sudo apt update
	sudo apt build-dep -y python3
	sudo apt install -y \
	  build-essential gdb lcov pkg-config \
	  libbz2-dev libffi-dev libgdbm-dev libgdbm-compat-dev liblzma-dev \
	  libncurses5-dev libreadline6-dev libsqlite3-dev libssl-dev \
	  lzma lzma-dev tk-dev uuid-dev zlib1g-dev
	cd /usr/local/src \
	&& if [ ! -d ./cpython ]; then sudo git clone https://github.com/python/cpython.git; fi

py-build: ## build CPython
	cd /usr/local/src/cpython \
	&& sudo git switch main \
	&& sudo git fetch \
	&& sudo git merge \
	&& sudo git checkout . \
	&& sudo git checkout refs/tags/v$(MF_PY_VER_PATCH) \
	&& sudo make distclean \
	&& sudo ./configure --with-pydebug \
	&& sudo make \
	&& sudo make altinstall
	python$(MF_PY_VER_MINOR) --version

py-vmu: ## update venv named myenv
	if [ -d $(MF_PY_VENV_MYENV) ]; then \
	  python$(MF_PY_VER_MINOR) -m venv $(MF_PY_VENV_MYENV) --upgrade; \
	else \
	  python$(MF_PY_VER_MINOR) -m venv $(MF_PY_VENV_MYENV); \
	fi
	. $(MF_PY_VENV_MYENV)/bin/activate \
	&& python$(MF_PY_VER_MINOR) -m pip config --site set global.trusted-host "pypi.org pypi.python.org files.pythonhosted.org" \
	&& python$(MF_PY_VER_MINOR) -m pip install --upgrade pip setuptools wheel \
	&& python$(MF_PY_VER_MINOR) -m pip install -r "$${HOME}"/dotfiles/etc/py_venv_myenv_requirements.txt \
	&& python$(MF_PY_VER_MINOR) -m pip check \
	&& python --version \
	&& deactivate

py-tag: ## show cpython tags
	sudo git -C /usr/local/src/cpython fetch
	sudo git -C /usr/local/src/cpython tag | grep v$(MF_PY_VER_MINOR)

r-init: ## install R
	# sudo apt update
	sudo apt install -y --no-install-recommends \
	  software-properties-common dirmngr
	wget -qO- \
	  https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc \
	  | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
	sudo add-apt-repository -y \
	  "deb https://cloud.r-project.org/bin/linux/ubuntu ""$$(lsb_release -cs)""-cran40/"
	sudo apt install -y --no-install-recommends r-base
	sudo apt install -y libcurl4-openssl-dev libxml2-dev libblas-dev liblapack-dev libavfilter-dev
	sudo apt install -y pandoc
	sudo R -e "install.packages('rmarkdown', dependencies=TRUE)"
	sudo R -e "install.packages('IRkernel', dependencies=TRUE)"
	# sudo R -e "install.packages('DiagrammeR', dependencies=TRUE)"
	# sudo R -e "install.packages('devtools', dependencies=TRUE)"
	. $(MF_PY_VENV_MYENV)/bin/activate \
	&& R -e "IRkernel::installspec()"

rust-init: ## install Rust
	sudo apt install -y cargo
	cargo install tokei

ubuntu-desktop:
	# Settings --> Accessibility --> Large Text
	# https://zenn.dev/wsuzume/articles/26b26106c3925e
	sudo apt install -y openssh-server
	sudo systemctl daemon-reload
	sudo systemctl enable ssh.service
	sudo systemctl start ssh.service

ubuntu-font:
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
