# MAKEFLAGS += --warn-undefined-variables
SHELL := /usr/bin/env bash
.SHELLFLAGS := -o errexit -o nounset -o pipefail -o posix -c
.DEFAULT_GOAL := help


# all targets are phony
.PHONY: $(grep -E '^[a-zA-Z_-]+:' $(MAKEFILE_LIST) | sed 's/://')


common: init-zshrc unlink link git-config \
	package-go package-rust \
	ghq-get-readonly \
	vim-build nvim-build pyenv-install pyenv-vmu \
	volta-init

ubuntu-minimal: init-zsh-ubuntu package-ubuntu common
	echo "import = ['~/.config/alacritty/common.toml', '~/.config/alacritty/ubuntu.toml']" > "$${HOME}"/.config/alacritty/alacritty.toml

ubuntu: ubuntu-minimal docker-init-ubuntu docker-systemd-ubuntu

ubuntu-server: ubuntu package-ubuntu-server  ## init for Ubuntu Server

ubuntu-desktop: ubuntu package-ubuntu-desktop  ## init for Ubuntu Desktop

wsl: ubuntu-minimal win-copy  ## init for WSL2 Ubuntu
	# https://tech-blog.cloud-config.jp/2024-06-18-wsl2-easiest-github-authentication
	sudo apt install -y wslu
	# https://inno-tech-life.com/dev/infra/wsl2-ssh-agent/
	eval `ssh-agent`
	echo "Restart WSL2"

mac: package-mac common  ## init for Mac
	defaults write com.apple.desktopservices DSDontWriteNetworkStores True
	killall Finder > /dev/null 2>&1
	echo "import = ['~/.config/alacritty/common.toml', '~/.config/alacritty/mac.toml']" > "$${HOME}"/.config/alacritty/alacritty.toml

mac-delete-ds_store:  ## delete .DS_Store in ~/src
	find "$${HOME}"/src -name ".DS_Store" -type f -ls -delete


init-zsh-ubuntu:
	sudo apt install -y zsh
	chsh -s "$$(which zsh)"

init-zshrc:
	# Zinit
	bash -c "$$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
	zsh -c ". "$${HOME}"/.local/share/zinit/zinit.git/zinit.zsh && zinit self-update"
	# Zsh
	echo "if test -f "$${HOME}"/src/github.com/i9wa4/dotfiles/dot.zshenv; then . "$${HOME}"/src/github.com/i9wa4/dotfiles/dot.zshenv; fi" >> "$${HOME}"/.zshenv
	echo "if test -f "$${HOME}"/src/github.com/i9wa4/dotfiles/dot.zshrc; then . "$${HOME}"/src/github.com/i9wa4/dotfiles/dot.zshrc; fi" >> "$${HOME}"/.zshrc

link:  ## make symbolic links
	# dotfiles
	ln -fs "$${HOME}"/src/github.com/i9wa4/dotfiles/dot.gitignore "$${HOME}"/.gitignore
	mkdir -p "$${HOME}"/.cache/vim
	# XDG_CONFIG_HOME
	. "$${HOME}"/src/github.com/i9wa4/dotfiles/dot.zshenv \
	&& mkdir -p "$${XDG_CONFIG_HOME}" \
	&& ln -fs "$${HOME}"/src/github.com/i9wa4/dotfiles/dot.config/alacritty         "$${XDG_CONFIG_HOME}" \
	&& ln -fs "$${HOME}"/src/github.com/i9wa4/dotfiles/dot.config/efm-langserver    "$${XDG_CONFIG_HOME}" \
	&& ln -fs "$${HOME}"/src/github.com/i9wa4/dotfiles/dot.config/nvim              "$${XDG_CONFIG_HOME}" \
	&& ln -fs "$${HOME}"/src/github.com/i9wa4/dotfiles/dot.config/skk               "$${XDG_CONFIG_HOME}" \
	&& ln -fs "$${HOME}"/src/github.com/i9wa4/dotfiles/dot.config/tmux              "$${XDG_CONFIG_HOME}" \
	&& ln -fs "$${HOME}"/src/github.com/i9wa4/dotfiles/dot.config/vim               "$${XDG_CONFIG_HOME}" \
	&& ln -fs "$${HOME}"/src/github.com/i9wa4/dotfiles/dot.config/zeno              "$${XDG_CONFIG_HOME}"
	# && cp -rf "$${HOME}"/src/github.com/i9wa4/dotfiles/dot.config/jupyter "$${XDG_CONFIG_HOME}" \
	# && cp -rf "$${HOME}"/src/github.com/i9wa4/dotfiles/dot.config/jupyter/* "$${PY_VENV_MYENV}"/share/jupyter

unlink:  ## unlink symbolic links
	# dotfiles
	if [ -L "$${HOME}"/.gitignore ]; then unlink "$${HOME}"/.gitignore; fi
	if [ -L "$${HOME}"/.vim ]; then unlink "$${HOME}"/.vim; else rm -rf "$${HOME}"/.vim; fi
	rm -rf "$${HOME}"/.cache/vim
	# XDG_CONFIG_HOME
	. "$${HOME}"/src/github.com/i9wa4/dotfiles/dot.zshenv \
	&& if [ -L "$${XDG_CONFIG_HOME}"/alacritty ];           then unlink "$${XDG_CONFIG_HOME}"/alacritty; fi \
	&& if [ -L "$${XDG_CONFIG_HOME}"/efm-langserver ];      then unlink "$${XDG_CONFIG_HOME}"/efm-langserver; fi \
	&& if [ -L "$${XDG_CONFIG_HOME}"/nvim ];                then unlink "$${XDG_CONFIG_HOME}"/nvim; fi \
	&& if [ -L "$${XDG_CONFIG_HOME}"/skk ];                 then unlink "$${XDG_CONFIG_HOME}"/skk; fi \
	&& if [ -L "$${XDG_CONFIG_HOME}"/tmux ];                then unlink "$${XDG_CONFIG_HOME}"/tmux; fi \
	&& if [ -L "$${XDG_CONFIG_HOME}"/vim ];                 then unlink "$${XDG_CONFIG_HOME}"/vim; fi \
	&& if [ -L "$${XDG_CONFIG_HOME}"/zeno ];                then unlink "$${XDG_CONFIG_HOME}"/zeno; fi

package-update:
	# OS-specific update
	_UNAME="$$(uname -a)"; \
	if [ "$$(echo "$${_UNAME}" | grep Darwin)" ]; then \
	  echo 'Hello, macOS!'; \
	  make package-mac-update; \
	elif [ "$$(echo "$${_UNAME}" | grep Ubuntu)" ]; then \
	  echo 'Hello, Ubuntu'; \
	  make package-ubuntu-update; \
	elif [ "$$(echo "$${_UNAME}" | grep WSL2)" ]; then \
	  echo 'Hello, WSL2!'; \
	  make package-ubuntu-update; \
	elif [ "$$(echo "$${_UNAME}" | grep arm)" ]; then \
	  echo 'Hello, Raspberry Pi!'; \
	elif [ "$$(echo "$${_UNAME}" | grep el7)" ]; then \
	  echo 'Hello, CentOS!'; \
	else \
	  echo 'Which OS are you using?'; \
	fi
	# OS common update
	make package-go
	make package-rust
	make volta-update
	make pyenv-update

package-ubuntu:
	sudo add-apt-repository -y ppa:git-core/ppa
	sudo apt update
	sudo apt upgrade -y
	sudo apt install -y \
	  bc \
	  curl \
	  fd-find \
	  fzf \
	  gh \
	  jq \
	  nkf \
	  ripgrep \
	  shellcheck \
	  ssh \
	  tmux \
	  unzip \
	  vim \
	  xsel \
	  zip
	# Vim
	# sudo sed -i 's/^# deb-src/deb-src/' /etc/apt/sources.list
	sudo sed -i 's/^Types: deb$$/Types: deb deb-src/' /etc/apt/sources.list.d/ubuntu.sources
	sudo apt update
	sudo apt build-dep -y vim
	# Neovim
	# https://github.com/neovim/neovim/blob/master/BUILD.md
	sudo apt install -y \
	  ninja-build gettext cmake unzip curl build-essential
	# Deno
	if [ -n "$$(command -v deno)" ]; then curl -fsSL https://deno.land/install.sh | bash; fi
	# pyenv
	# https://github.com/pyenv/pyenv/wiki#suggested-build-environment
	sudo rm -rf "$${HOME}"/.pyenv
	curl https://pyenv.run | bash
	sudo apt install -y \
	  build-essential libssl-dev zlib1g-dev \
	  libbz2-dev libreadline-dev libsqlite3-dev curl git \
	  libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
	# Go
	sudo add-apt-repository -y ppa:longsleep/golang-backports
	sudo apt update
	sudo apt install -y golang-go
	# Rust
	curl https://sh.rustup.rs -sSf | sh
	# AWS CLI
	# https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
	cd \
	&& curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
	&& unzip awscliv2.zip \
	&& sudo ./aws/install \
	&& rm awscliv2.zip
	# gcloud CLI
	sudo apt-get install -y apt-transport-https ca-certificates gnupg curl
	curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
	curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
	echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
	sudo apt-get update && sudo apt-get install -y google-cloud-cli

package-ubuntu-update:
	sudo apt update
	sudo apt upgrade -y
	# Deno
	deno upgrade
	# Rust
	rustup update
	# AWS CLI
	# https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
	cd \
	&& curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
	&& unzip -fo awscliv2.zip \
	&& sudo ./aws/install --update \
	&& rm awscliv2.zip \

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
	&& rm -rf MyricaM \

package-ubuntu-server:
	# Settings --> Accessibility --> Large Text
	# https://zenn.dev/wsuzume/articles/26b26106c3925e
	sudo apt install -y openssh-server
	sudo systemctl daemon-reload
	sudo systemctl enable ssh.service
	sudo systemctl start ssh.service

package-mac:
	# https://brew.sh/
	/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	# https://namileriblog.com/mac/rust_alacritty/
	brew install --cask alacritty
	# Rectangle
	brew install --cask rectangle
	# Arc
	brew install --cask arc
	# CLI
	brew -v
	brew update
	brew upgrade
	brew install \
	  fd \
	  fzf \
	  gh \
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
	# Neovim
	# https://github.com/neovim/neovim/blob/master/BUILD.md
	brew install ninja cmake gettext curl
	# Deno
	brew install deno
	# pyenv
	# https://github.com/pyenv/pyenv/wiki#suggested-build-environment
	sudo rm -rf "$${HOME}"/.pyenv
	curl https://pyenv.run | bash
	# brew install pyenv
	brew install openssl readline sqlite3 xz zlib tcl-tk
	# Go
	brew install go
	# Rust
	brew install rustup-init && rustup-init
	# AWS CLI
	brew install awscli
	# gcloud CLI
	brew install --cask google-cloud-sdk

package-mac-update:
	brew update
	brew upgrade

package-go:
	go install github.com/evilmartians/lefthook@latest
	go install github.com/mattn/efm-langserver@latest
	go install github.com/rhysd/vim-startuptime@latest
	go install github.com/x-motemen/ghq@latest

package-rust:
	cargo install --git https://github.com/XAMPPRocky/tokei.git tokei

ghq-get-readonly:
	cat etc/ghq-list-readonly.txt | ghq get -p

ghq-get-private:
	cat etc/ghq-list-private.txt | ghq get -p

ghq-get-company:
	cat ~/str/etc/ghq-list-company.txt | ghq get -p

ghq-backup-private:
	ghq list > etc/ghq-list-private.txt

ghq-backup-company:
	mkdir -p ~/str/etc \
	&& ghq list > ~/str/etc/ghq-list-company.txt

git-config:
	git config --global gpg.format ssh
	git config --global color.ui auto
	git config --global commit.gpgsign true
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
	git config --global user.signingkey ~/.ssh/github.pub

vim-build:  ## build Vim
	cd ~/src/github.com/vim/vim/src \
	&& git checkout master \
	&& make distclean \
	&& ./configure \
	  --disable-gui \
	  --enable-fail-if-missing \
	  --enable-multibyte \
	  --enable-python3interp=dynamic \
	  --prefix="$${HOME}" \
	  --with-features=huge \
	&& make \
	&& make install \
	&& hash -r \

nvim-build:  ## build Neovim
	cd ~/src/github.com/neovim/neovim \
	&& git checkout refs/tags/stable \
	&& make distclean \
	&& make \
	  BUNDLED_CMAKE_FLAG='-DUSE_BUNDLED_TS_PARSERS=OFF' \
	  CMAKE_BUILD_TYPE=Release \
	  CMAKE_INSTALL_PREFIX="$${HOME}" \
	&& make install \
	&& hash -r \

docker-init-ubuntu:
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

docker-systemd-ubuntu:
	sudo systemctl daemon-reload
	sudo systemctl start docker
	sudo systemctl enable docker

nix-install-ubuntu:  ## install Nix
	# curl -L https://nixos.org/nix/install | sh
	curl -L https://nixos.org/nix/install | sh -s -- --daemon
	# uninstall:
	# https://github.com/NixOS/nix/issues/1402#issuecomment-312496360

pyenv-install: pyenv-list  ## install Python (e.g. make pyenv-install PY_VER_PATCH=3.13.0)
	. "$${HOME}"/src/github.com/i9wa4/dotfiles/dot.zshenv \
	&& pyenv install "$(PY_VER_PATCH)" \
	&& pyenv global "$(PY_VER_PATCH)" \
	&& pyenv versions \
	&& python -m pip config --site set global.require-virtualenv true

pyenv-install-latest: pyenv-list  ## install latest Python
	_py_ver_latest="$$(tail -n1 "$${HOME}"/.cache/pyenv-list.txt)" \
	&& pyenv install "$${_py_ver_latest}" \
	&& pyenv global "$${_py_ver_latest}" \
	&& pyenv versions \
	&& python -m pip config --site set global.require-virtualenv true

pyenv-list:  ## show installed Python versions
	. "$${HOME}"/src/github.com/i9wa4/dotfiles/dot.zshenv \
	&& echo "[pyenv] Installable Python "$${PY_VER_MINOR}" or newer versions:" \
	&& available_versions="$$(pyenv install --list | sed 's/ //g' | grep -v '[a-zA-Z]' | sort -V)" \
	&& mkdir -p "$${HOME}"/.cache \
	&& echo "$${available_versions}" | tail -n +$$( \
	    echo "$${available_versions}" \
	    | grep -n '^'"$${PY_VER_MINOR}" | cut -f1 -d: | head -n1 \
	  ) | tee "$${HOME}"/.cache/pyenv-list.txt \
	&& echo "[pyenv] Installed Python versions:" \
	&& pyenv versions

pyenv-update:  ## update pyenv
	git -C "$${HOME}"/.pyenv pull

define REQUIREMENTS_PY_VENV_MYENV
autopep8
charset-normalizer<3,>=2
flake8
ipykernel
japanize-matplotlib
jupyterlab
jupytext
matplotlib
numpy
pandas
py
pyautogui
pynvim
python-lsp-server[all]
quarto-cli
scikit-learn
endef
export REQUIREMENTS_PY_VENV_MYENV

pyenv-vmu:  ## update venv named myenv
	# https://dev.classmethod.jp/articles/change-venv-python-version/
	. "$${HOME}"/src/github.com/i9wa4/dotfiles/dot.zshenv \
	&& if [ -d "$${PY_VENV_MYENV}" ]; then \
	  python -m venv "$${PY_VENV_MYENV}" --clear; \
	else \
	  python -m venv "$${PY_VENV_MYENV}"; \
	fi \
	&& . "$${PY_VENV_MYENV}"/bin/activate \
	&& python -m pip config --site set global.trusted-host "pypi.org pypi.python.org files.pythonhosted.org" \
	&& python -m pip install --upgrade pip setuptools wheel \
	&& echo "$${REQUIREMENTS_PY_VENV_MYENV}" | xargs python -m pip install \
	&& python -m pip check \
	&& python --version \
	&& deactivate

tfenv-install: tfenv-list  ## install Terraform (e.g. make tfenv-install TF_VER_PATCH=1.9.3)
	. "$${HOME}"/src/github.com/i9wa4/dotfiles/dot.zshenv \
	&& tfenv install "$(TF_VER_PATCH)" \
	&& tfenv use "$(TF_VER_PATCH)" \
	&& terraform version

tfenv-install-latest: tfenv-list  ## install latest Terraform
	_tf_ver_latest="$$(tail -n1 "$${HOME}"/.cache/tfenv-list.txt)" \
	&& tfenv install "$${_tf_ver_latest}" \
	&& tfenv use "$${_tf_ver_latest}" \
	&& terraform version

tfenv-list:  ## show installed Terraform versions
	. "$${HOME}"/src/github.com/i9wa4/dotfiles/dot.zshenv \
	&& echo "[tfenv] Installable Terraform "${TF_VER_MINOR}" or newer versions:" \
	&& available_versions="$$(tfenv list-remote | grep -v '[a-zA-Z]' | sort -V)" \
	&& mkdir -p "$${HOME}"/.cache \
	&& echo "$${available_versions}" | tail -n +$$( \
	    echo "$${available_versions}" \
	    | grep -n '^'"$${TF_VER_MINOR}" | cut -f1 -d: | head -n1 \
	  ) | tee "$${HOME}"/.cache/tfenv-list.txt \
	&& echo "[tfenv] Installed Terraform versions:" \
	&& tfenv list

volta-init:
	curl https://get.volta.sh | bash
	"$${HOME}"/.volta/bin/volta install node
	echo "Restart Shell"

volta-update:
	curl https://get.volta.sh | bash

define WSLCONF_IN_WSL
[boot]
systemd=true

[interop]
appendWindowsPath=true
endef
export WSLCONF_IN_WSL

define WSLCONFIG_IN_WINDOWS
[wsl2]
localhostForwarding=true
processors=2
swap=0

[experimental]
autoMemoryReclaim=gradual
endef
export WSLCONFIG_IN_WINDOWS

MF_WIN_UTIL_DIR := /mnt/c/work/util

win-copy:  ## copy config files for Windows
	# WSL2
	# sudo cp -f "$${HOME}"/src/github.com/i9wa4/dotfiles/etc/wsl.conf /etc/wsl.conf
	echo "$${WSLCONF_IN_WSL}" | sudo tee /etc/wsl.conf
	# Windows copy
	rm -rf $(MF_WIN_UTIL_DIR)
	mkdir -p $(MF_WIN_UTIL_DIR)
	cp -rf  "$${HOME}"/src/github.com/i9wa4/dotfiles/bin                        $(MF_WIN_UTIL_DIR)
	cp -rf  "$${HOME}"/src/github.com/i9wa4/dotfiles/dot.config                 $(MF_WIN_UTIL_DIR)
	cp -rf  "$${HOME}"/src/github.com/i9wa4/dotfiles/dot.vscode                 $(MF_WIN_UTIL_DIR)
	cp -rf  "$${HOME}"/src/github.com/i9wa4/dotfiles/etc                        $(MF_WIN_UTIL_DIR)
	cp -f   "$${HOME}"/src/github.com/i9wa4/dotfiles/bin/windows/win-copy.bat   $(MF_WIN_UTIL_DIR)
	rm -f   $(MF_WIN_UTIL_DIR)/bin/windows/win-copy.bat
	echo "$${REQUIREMENTS_PY_VENV_MYENV}" | tee $(MF_WIN_UTIL_DIR)/etc/requirements.txt
	echo "$${WSLCONFIG_IN_WINDOWS}" | tee $(MF_WIN_UTIL_DIR)/etc/dot.wslconfig

help:  ## print this help
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# - [Makefileを自己文書化する | POSTD](https://postd.cc/auto-documented-makefile/)
# - [タスク・ランナーとしてのMake \#Makefile - Qiita](https://qiita.com/shakiyam/items/cdd3c11eba978202a628)
# - [Makefile の関数一覧 | 晴耕雨読](https://tex2e.github.io/blog/makefile/functions)
