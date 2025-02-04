# - [Makefileを自己文書化する | POSTD](https://postd.cc/auto-documented-makefile/)
# - [タスク・ランナーとしてのMake \#Makefile - Qiita](https://qiita.com/shakiyam/items/cdd3c11eba978202a628)
# - [Makefile の関数一覧 | 晴耕雨読](https://tex2e.github.io/blog/makefile/functions)
# MAKEFLAGS += --warn-undefined-variables
SHELL := /usr/bin/env bash
# .SHELLFLAGS := -o verbose -o xtrace -o errexit -o nounset -o pipefail -o posix -c
.SHELLFLAGS := -o errexit -o nounset -o pipefail -o posix -c
.DEFAULT_GOAL := help

# all targets are phony
.PHONY: $(grep -E '^[a-zA-Z_-]+:' $(MAKEFILE_LIST) | sed 's/://')

help:  ## print this help
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

debug:
	@echo uname: "$$(uname -a)"
	@echo dotfiles: $(MF_DOTFILES_DIR)
	@echo dotfiles: "$(MF_DOTFILES_DIR)"
	@echo shell: "$$0"
	@echo .zshenv load test:
	. $(MF_DOTFILES_DIR)/dot.zshenv


# --------------------------------------
# Global Variables
#
MF_GITHUB_DIR := "$${HOME}"/ghq/github.com
MF_DOTFILES_DIR := $(MF_GITHUB_DIR)/i9wa4/dotfiles


# --------------------------------------
# OS-common Initialization
#
common-init: zsh-init zinit-install \
	unlink link \
	git-init \
	ghq-get-essential \
	vim-build nvim-build \
	act-build \
	pyenv-install \
	package-go package-rust \
	volta-install

# --------------------------------------
# Tasks for macOS
#
mac-init: package-mac-install common-init mac-alacritty-init mac-ghostty-init  ## init for Mac
	defaults write com.apple.desktopservices DSDontWriteNetworkStores True
	defaults write com.apple.Finder QuitMenuItem -bool YES
	killall Finder > /dev/null 2>&1

mac-clean:  ## delete .DS_Store and Extended Attributes
	fd ".DS_Store" "$${HOME}" --hidden --no-ignore --exclude "Library/**" | xargs -t rm -f
	xattr -rc $(MF_GITHUB_DIR)

mac-skk-copy:  ## copy SKK dictionaries for Mac
	_macskk_dict_dir="$${HOME}"/Library/Containers/net.mtgto.inputmethod.macSKK/Data/Documents/Dictionaries \
	&& cp -f $(MF_DOTFILES_DIR)/dot.config/skk/mydict.utf8 "$${_macskk_dict_dir}"/skk-jisyo.utf8 \
	&& cp -f $(MF_GITHUB_DIR)/skk-dev/dict/SKK-JISYO.L "$${_macskk_dict_dir}" \
	&& cp -f $(MF_GITHUB_DIR)/skk-dev/dict/SKK-JISYO.jinmei "$${_macskk_dict_dir}" \
	&& cp -f $(MF_GITHUB_DIR)/uasi/skk-emoji-jisyo/SKK-JISYO.emoji.utf8 "$${_macskk_dict_dir}"

define MF_MAC_ALACRITTY
[general]
import = [
    '~/.config/alacritty/common.toml'
]
endef
export MF_MAC_ALACRITTY

mac-alacritty-init:
	echo "$${MF_MAC_ALACRITTY}" | tee "$${HOME}"/.config/alacritty/alacritty.toml

define MF_MAC_GHOSTTY
config-file = "config-common"
endef
export MF_MAC_GHOSTTY

mac-ghostty-init:
	echo "$${MF_MAC_GHOSTTY}" | tee "$${HOME}"/.config/ghostty/config

# --------------------------------------
# Tasks for Ubuntu
#
ubuntu-minimal-init: package-ubuntu-install common-init

ubuntu-server-init: ubuntu-minimal-init  docker-install-ubuntu docker-init-ubuntu package-ubuntu-server-install  ## init for Ubuntu Server

ubuntu-desktop-init: ubuntu-server-init package-ubuntu-desktop-install  ## init for Ubuntu Desktop

# --------------------------------------
# Tasks for Windows & WSL
#
wsl-init: ubuntu-minimal-init win-copy  ## init for WSL2 Ubuntu
	# https://tech-blog.cloud-config.jp/2024-06-18-wsl2-easiest-github-authentication
	sudo apt install -y wslu
	# https://inno-tech-life.com/dev/infra/wsl2-ssh-agent/
	eval `ssh-agent`
	echo "Restart WSL2"

wsl-ghostty-install:
	# https://www.virtualizationhowto.com/2024/12/install-ghostty-in-windows-using-wsl/
	sudo apt install -y \
	  libadwaita-1-dev \
	  libgtk-4-dev
	sudo snap install --beta zig --classic
	ghq get -p ghostty-org/ghostty
	cd $(MF_GITHUB_DIR)/ghostty-org/ghostty \
	&& sudo zig build -p "$${HOME}"/.local -Doptimize=ReleaseFast

define MF_WIN_GHOSTTY
config-file = "config-common"
endef
export MF_WIN_GHOSTTY

win-ghostty-init:
	echo "$${MF_WIN_GHOSTTY}" | tee "$${HOME}"/.config/ghostty/config

define MF_WSLCONF_IN_WSL
[boot]
systemd=true

[interop]
appendWindowsPath=true
endef
export MF_WSLCONF_IN_WSL

define MF_WSLCONFIG_IN_WINDOWS
[wsl2]
localhostForwarding=true
processors=2
swap=0

[experimental]
autoMemoryReclaim=gradual
endef
export MF_WSLCONFIG_IN_WINDOWS

MF_WIN_UTIL_DIR := /mnt/c/work/util

win-copy:  ## copy config files for Windows
	# WSL2
	echo "$${MF_WSLCONF_IN_WSL}" | sudo tee /etc/wsl.conf
	# Windows
	rm -rf $(MF_WIN_UTIL_DIR)
	mkdir -p $(MF_WIN_UTIL_DIR)/skk
	cp -rf $(MF_DOTFILES_DIR)/bin $(MF_WIN_UTIL_DIR)
	cp -rf $(MF_DOTFILES_DIR)/dot.config $(MF_WIN_UTIL_DIR)
	cp -rf $(MF_DOTFILES_DIR)/dot.vscode $(MF_WIN_UTIL_DIR)
	cp -rf $(MF_DOTFILES_DIR)/etc $(MF_WIN_UTIL_DIR)
	cp -f $(MF_GITHUB_DIR)/uasi/skk-emoji-jisyo/SKK-JISYO.emoji.utf8 $(MF_WIN_UTIL_DIR)/skk
	cp -f $(MF_GITHUB_DIR)/skk-dev/dict/SKK-JISYO.L $(MF_WIN_UTIL_DIR)/skk
	cp -f $(MF_GITHUB_DIR)/skk-dev/dict/SKK-JISYO.jinmei $(MF_WIN_UTIL_DIR)/skk
	echo "$${MF_WSLCONFIG_IN_WINDOWS}" | tee $(MF_WIN_UTIL_DIR)/etc/dot.wslconfig


# --------------------------------------
# Symbolic Links
#
link:  ## make symbolic links
	# dotfiles
	ln -fs $(MF_DOTFILES_DIR)/dot.gitignore "$${HOME}"/.gitignore
	mkdir -p "$${HOME}"/.cache/vim
	# XDG_CONFIG_HOME
	. $(MF_DOTFILES_DIR)/dot.zshenv \
	&& mkdir -p "$${XDG_CONFIG_HOME}" \
	&& ln -fs $(MF_DOTFILES_DIR)/dot.config/alacritty "$${XDG_CONFIG_HOME}" \
	&& ln -fs $(MF_DOTFILES_DIR)/dot.config/efm-langserver "$${XDG_CONFIG_HOME}" \
	&& ln -fs $(MF_DOTFILES_DIR)/dot.config/ghostty "$${XDG_CONFIG_HOME}" \
	&& ln -fs $(MF_DOTFILES_DIR)/dot.config/nvim "$${XDG_CONFIG_HOME}" \
	&& ln -fs $(MF_DOTFILES_DIR)/dot.config/skk "$${XDG_CONFIG_HOME}" \
	&& ln -fs $(MF_DOTFILES_DIR)/dot.config/tmux "$${XDG_CONFIG_HOME}" \
	&& ln -fs $(MF_DOTFILES_DIR)/dot.config/vim "$${XDG_CONFIG_HOME}" \
	&& ln -fs $(MF_DOTFILES_DIR)/dot.config/zeno "$${XDG_CONFIG_HOME}"
	# && cp -rf $(MF_DOTFILES_DIR)/dot.config/jupyter "$${XDG_CONFIG_HOME}" \
	# && cp -rf $(MF_DOTFILES_DIR)/dot.config/jupyter/* "$${PY_VENV_MYENV}"/share/jupyter
	# OS-specific link & copy
	_uname="$$(uname -a)"; \
	if [ "$$(echo "$${_uname}" | grep Darwin)" ]; then \
	  echo 'Hello, macOS!'; \
	  make mac-clean; \
	  _code_setting_dir="$${HOME}""/Library/Application Support/Code/User"; \
	  rm -rf "$${_code_setting_dir}"/snippets; \
	  mkdir -p "$${_code_setting_dir}"/snippets; \
	  cp -f $(MF_DOTFILES_DIR)/dot.config/vim/snippet/* "$${_code_setting_dir}"/snippets; \
	  ln -fs $(MF_DOTFILES_DIR)/dot.vscode/settings.json "$${_code_setting_dir}"; \
	elif [ "$$(echo "$${_uname}" | grep Ubuntu)" ]; then \
	  echo 'Hello, Ubuntu'; \
	elif [ "$$(echo "$${_uname}" | grep WSL2)" ]; then \
	  echo 'Hello, WSL2!'; \
	  make win-copy; \
	  _code_setting_dir="$${HOME}"/.vscode-server/data/Machine; \
	  rm -rf "$${_code_setting_dir}"/snippets; \
	  mkdir -p "$${_code_setting_dir}"/snippets; \
	  cp -f $(MF_DOTFILES_DIR)/dot.config/vim/snippet/* "$${_code_setting_dir}"/snippets; \
	  ln -fs $(MF_DOTFILES_DIR)/dot.vscode/settings.json "$${_code_setting_dir}"; \
	elif [ "$$(echo "$${_uname}" | grep arm)" ]; then \
	  echo 'Hello, Raspberry Pi!'; \
	elif [ "$$(echo "$${_uname}" | grep el7)" ]; then \
	  echo 'Hello, CentOS!'; \
	else \
	  echo 'Which OS are you using?'; \
	fi


unlink:  ## unlink symbolic links
	# dotfiles
	if [ -L "$${HOME}"/.gitignore ]; then unlink "$${HOME}"/.gitignore; fi
	if [ -L "$${HOME}"/.vim ]; then unlink "$${HOME}"/.vim; else rm -rf "$${HOME}"/.vim; fi
	rm -rf "$${HOME}"/.cache/vim
	# XDG_CONFIG_HOME
	. $(MF_DOTFILES_DIR)/dot.zshenv \
	&& if [ -L "$${XDG_CONFIG_HOME}"/alacritty ]; then unlink "$${XDG_CONFIG_HOME}"/alacritty; fi \
	&& if [ -L "$${XDG_CONFIG_HOME}"/efm-langserver ]; then unlink "$${XDG_CONFIG_HOME}"/efm-langserver; fi \
	&& if [ -L "$${XDG_CONFIG_HOME}"/ghostty ]; then unlink "$${XDG_CONFIG_HOME}"/ghostty; fi \
	&& if [ -L "$${XDG_CONFIG_HOME}"/nvim ]; then unlink "$${XDG_CONFIG_HOME}"/nvim; fi \
	&& if [ -L "$${XDG_CONFIG_HOME}"/skk ]; then unlink "$${XDG_CONFIG_HOME}"/skk; fi \
	&& if [ -L "$${XDG_CONFIG_HOME}"/tmux ]; then unlink "$${XDG_CONFIG_HOME}"/tmux; fi \
	&& if [ -L "$${XDG_CONFIG_HOME}"/vim ]; then unlink "$${XDG_CONFIG_HOME}"/vim; fi \
	&& if [ -L "$${XDG_CONFIG_HOME}"/zeno ]; then unlink "$${XDG_CONFIG_HOME}"/zeno; fi


# --------------------------------------
# Package Management
#
package-go:
	go install github.com/evilmartians/lefthook@latest
	go install github.com/mattn/efm-langserver@latest
	go install github.com/mikefarah/yq/v4@latest
	go install github.com/rhysd/actionlint/cmd/actionlint@latest
	go install github.com/rhysd/vim-startuptime@latest
	go install github.com/x-motemen/ghq@latest
	go install mvdan.cc/sh/v3/cmd/shfmt@latest

package-rust:
	. $(MF_DOTFILES_DIR)/dot.zshenv \
	&& cargo install --git https://github.com/XAMPPRocky/tokei.git tokei

package-update:
	# OS common update
	make package-go
	make package-rust
	make volta-update
	make pyenv-update
	# Deno
	. $(MF_DOTFILES_DIR)/dot.zshenv \
	&& deno upgrade "$${DENO_VER_PATCH}"
	# OS-specific update
	_uname="$$(uname -a)"; \
	if [ "$$(echo "$${_uname}" | grep Darwin)" ]; then \
	  echo 'Hello, macOS!'; \
	  make package-mac-update; \
	elif [ "$$(echo "$${_uname}" | grep Ubuntu)" ]; then \
	  echo 'Hello, Ubuntu'; \
	  make package-ubuntu-update; \
	elif [ "$$(echo "$${_uname}" | grep WSL2)" ]; then \
	  echo 'Hello, WSL2!'; \
	  make package-ubuntu-update; \
	elif [ "$$(echo "$${_uname}" | grep arm)" ]; then \
	  echo 'Hello, Raspberry Pi!'; \
	elif [ "$$(echo "$${_uname}" | grep el7)" ]; then \
	  echo 'Hello, CentOS!'; \
	else \
	  echo 'Which OS are you using?'; \
	fi

package-mac-install:
	# https://brew.sh/
	/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	. $(MF_DOTFILES_DIR)/dot.zshenv \
	&& brew -v \
	&& brew update \
	&& brew upgrade \
	&& brew install --cask \
	  alacritty \
	  docker \
	  font-myricam \
	  ghostty \
	  google-drive \
	  mtgto/macskk/macskk \
	  rectangle \
	  visual-studio-code \
	  zoom \
	&& brew install \
	  fd \
	  fzf \
	  gh \
	  git \
	  hadolint \
	  jq \
	  nvim \
	  ripgrep \
	  shellcheck \
	  tflint \
	  tmux \
	  vim \
	  wget \
	  zsh \
	&& brew install ninja cmake gettext curl \  # Neovim
	&& if [ -n "$$(command -v deno)" ]; then curl -fsSL https://deno.land/install.sh | bash; fi \  # Deno
	&& sudo rm -rf "$${HOME}"/.pyenv \  # pyenv
	&& curl https://pyenv.run | bash \
	&& brew install openssl readline sqlite3 xz zlib tcl-tk \
	&& brew install go \  # Go
	&& brew install rustup-init && rustup-init \  # Rust
	&& brew install awscli \  # AWS CLI
	&& brew install --cask aws-vpn-client \
	&& brew install --cask google-cloud-sdk \  # gcloud CLI
	&& brew install --cask snowflake-snowsql  # SnowSQL

package-mac-update:
	brew update
	brew upgrade

package-ubuntu-install:
	sudo apt install -y zsh
	chsh -s "$$(which zsh)"
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
	  luajit \
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
	# Rust
	rustup update

package-ubuntu-server-install:
	# Settings --> Accessibility --> Large Text
	# https://zenn.dev/wsuzume/articles/26b26106c3925e
	sudo apt install -y openssh-server
	sudo systemctl daemon-reload
	sudo systemctl start ssh.service
	sudo systemctl enable ssh.service

package-ubuntu-desktop-install:
	sudo add-apt-repository -y ppa:aslatter/ppa
	sudo apt update
	# https://myrica.estable.jp/
	cd \
	&& curl -OL https://github.com/tomokuni/Myrica/raw/master/product/MyricaM.zip \
	&& unzip -d MyricaM MyricaM.zip \
	&& sudo cp MyricaM/MyricaM.TTC /usr/share/fonts/truetype/ \
	&& fc-cache -fv \
	&& rm -f MyricaM.zip \
	&& rm -rf MyricaM \


# --------------------------------------
#  Tools
#
act-build:  ## build act
	cd $(MF_GITHUB_DIR)/nektos/act \
	&& make build

awscli-update-ubuntu:  ## update AWS CLI for Ubuntu
	# AWS CLI
	# https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
	cd \
	&& curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
	&& unzip -fo awscliv2.zip \
	&& sudo ./aws/install --update \
	&& rm awscliv2.zip \

docker-install-ubuntu:
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

docker-init-ubuntu:
	sudo systemctl daemon-reload
	sudo systemctl start docker
	sudo systemctl enable docker

ghq-get-essential:
	_list_path=$(MF_DOTFILES_DIR)/etc/ghq-list-essential.txt \
	&& if [ -f "$${_list_path}" ]; then \
	  cat "$${_list_path}" | ghq get -p; \
	fi

ghq-get-local:
	. "$${HOME}"/.zshenv \
	&& _list_path="$${GHQ_LIST_LOCAL_PATH}" \
	&& if [ -f "$${_list_path}" ]; then \
	  cat "$${_list_path}" | ghq get -p; \
	fi

ghq-backup-local:
	. "$${HOME}"/.zshenv \
	&& _list_path="$${GHQ_LIST_LOCAL_PATH}" \
	&& ghq list > "$${_list_path}" \
	&& sort --unique "$${_list_path}" -o "$${_list_path}"

git-init:
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
	git config --global ghq.root ~/ghq
	git config --global gpg.format ssh
	git config --global grep.lineNumber true
	git config --global http.sslVerify false
	git config --global init.defaultBranch main
	git config --global merge.conflictstyle diff3
	git config --global merge.tool vimdiff
	git config --global mergetool.prompt false
	git config --global mergetool.vimdiff.path vim
	git config --global push.default current
	git config --global user.signingkey ~/.ssh/github.pub

nvim-build:  ## build Neovim
	cd $(MF_GITHUB_DIR)/neovim/neovim \
	&& git checkout refs/tags/stable \
	&& make distclean \
	&& make \
	  BUNDLED_CMAKE_FLAG='-DUSE_BUNDLED_TS_PARSERS=OFF' \
	  CMAKE_BUILD_TYPE=Release \
	  CMAKE_INSTALL_PREFIX="$${HOME}"/.local \
	&& make install \
	&& hash -r \

pyenv-install: pyenv-list  ## install Python (e.g. make pyenv-install PY_VER_PATCH=3.13.0)
	. $(MF_DOTFILES_DIR)/dot.zshenv \
	&& pyenv install "$(PY_VER_PATCH)" --skip-existing \
	&& pyenv global "$(PY_VER_PATCH)" \
	&& pyenv versions \
	&& python -m pip config --site set global.require-virtualenv true

pyenv-install-latest: pyenv-list  ## install latest Python
	_py_ver_latest="$$(tail -n1 "$${HOME}"/.cache/pyenv-list.txt)" \
	&& pyenv install "$${_py_ver_latest}" --skip-existing \
	&& pyenv global "$${_py_ver_latest}" \
	&& pyenv versions \
	&& python -m pip config --site set global.require-virtualenv true

pyenv-list:  ## show installed Python versions
	@. $(MF_DOTFILES_DIR)/dot.zshenv \
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

python-venv:  ## install/update Python venv (e.g. make python-venv VENV_PATH="${PY_VENV_MYENV}" REQUIREMENTS_PATH="${HOME}"/ghq/github.com/i9wa4/dotfiles/etc/requirements-venv-myenv.txt)
	# https://dev.classmethod.jp/articles/change-venv-python-version/
	. $(MF_DOTFILES_DIR)/dot.zshenv \
	&& if [ -d "$(VENV_PATH)" ]; then \
	  python -m venv "$(VENV_PATH)" --clear; \
	else \
	  python -m venv "$(VENV_PATH)"; \
	fi \
	&& . "$(VENV_PATH)"/bin/activate \
	&& python -m pip config --site set global.trusted-host "pypi.org pypi.python.org files.pythonhosted.org" \
	&& python -m pip install --upgrade pip setuptools wheel \
	&& if [ -r "$(REQUIREMENTS_PATH)" ]; then python -m pip install --requirement "$(REQUIREMENTS_PATH)"; fi \
	&& python -m pip check \
	&& python --version \
	&& deactivate

tfenv-install: tfenv-list  ## install Terraform (e.g. make tfenv-install TF_VER_PATCH=1.9.3)
	. $(MF_DOTFILES_DIR)/dot.zshenv \
	&& tfenv install "$(TF_VER_PATCH)" \
	&& tfenv use "$(TF_VER_PATCH)" \
	&& terraform version

tfenv-install-latest: tfenv-list  ## install latest Terraform
	_tf_ver_latest="$$(tail -n1 "$${HOME}"/.cache/tfenv-list.txt)" \
	&& tfenv install "$${_tf_ver_latest}" \
	&& tfenv use "$${_tf_ver_latest}" \
	&& terraform version

tfenv-list:  ## show installed Terraform versions
	@. $(MF_DOTFILES_DIR)/dot.zshenv \
	&& echo "[tfenv] Installable Terraform "${TF_VER_MINOR}" or newer versions:" \
	&& available_versions="$$(tfenv list-remote | grep -v '[a-zA-Z]' | sort -V)" \
	&& mkdir -p "$${HOME}"/.cache \
	&& echo "$${available_versions}" | tail -n +$$( \
	    echo "$${available_versions}" \
	    | grep -n '^'"$${TF_VER_MINOR}" | cut -f1 -d: | head -n1 \
	  ) | tee "$${HOME}"/.cache/tfenv-list.txt \
	&& echo "[tfenv] Installed Terraform versions:" \
	&& tfenv list

vim-build:  ## build Vim
	_uname="$$(uname -a)"; \
	if [ "$$(echo "$${_uname}" | grep Darwin)" ]; then \
	  echo 'Hello, macOS!'; \
	  _lua_prefix="$$(brew --prefix)"; \
	elif [ "$$(echo "$${_uname}" | grep Ubuntu)" ]; then \
	  echo 'Hello, Ubuntu'; \
	  _lua_prefix="/usr"; \
	elif [ "$$(echo "$${_uname}" | grep WSL2)" ]; then \
	  echo 'Hello, WSL2!'; \
	  _lua_prefix="/usr"; \
	elif [ "$$(echo "$${_uname}" | grep arm)" ]; then \
	  echo 'Hello, Raspberry Pi!'; \
	elif [ "$$(echo "$${_uname}" | grep el7)" ]; then \
	  echo 'Hello, CentOS!'; \
	else \
	  echo 'Which OS are you using?'; \
	fi \
	&& cd $(MF_GITHUB_DIR)/vim/vim/src \
	&& git checkout master \
	&& make distclean \
	&& ./configure \
	  --disable-gui \
	  --enable-fail-if-missing \
	  --enable-luainterp=dynamic --with-luajit --with-lua-prefix="$${_lua_prefix}" \
	  --enable-multibyte \
	  --enable-python3interp=dynamic \
	  --prefix="$${HOME}"/.local \
	  --with-features=huge \
	&& make \
	&& make install \
	&& hash -r \

volta-install:
	curl https://get.volta.sh | bash
	"$${HOME}"/.volta/bin/volta install node
	echo "Restart Shell"

volta-update:
	curl https://get.volta.sh | bash

zinit-install:
	# Zinit
	bash -c "$$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
	zsh -c ". "$${HOME}"/.local/share/zinit/zinit.git/zinit.zsh && zinit self-update"

zsh-init:
	# Zsh
	echo "if [ -r $(MF_DOTFILES_DIR)/dot.zshenv ]; then . $(MF_DOTFILES_DIR)/dot.zshenv; fi" >> "$${HOME}"/.zshenv
	echo "if [ -r $(MF_DOTFILES_DIR)/dot.zshrc ]; then . $(MF_DOTFILES_DIR)/dot.zshrc; fi" >> "$${HOME}"/.zshrc
