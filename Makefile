# - [Makefileを自己文書化する | POSTD](https://postd.cc/auto-documented-makefile/)
# - [タスク・ランナーとしてのMake \#Makefile - Qiita](https://qiita.com/shakiyam/items/cdd3c11eba978202a628)
# - [Makefile の関数一覧 | 晴耕雨読](https://tex2e.github.io/blog/makefile/functions)
# - [Makefileでシェルスクリプトを便利にする.ONESHELL](https://zenn.dev/mirablue/articles/20241208-make-oneshell)
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


# --------------------------------------
# Global Variables
#
MF_DOTFILES_DIR := "$${HOME}"/ghq/github.com/i9wa4/dotfiles
MF_GITHUB_DIR := "$${HOME}"/ghq/github.com


# --------------------------------------
# OS-common Tasks
#
common-init: package-install zinit-install zsh-init unlink link git-config tmux-init ghq-get-essential

common-clean:  ## clean for all OS
	# OS-common clean
	rm -rf "$${HOME}"/.npm
	# OS-specific clean
	_uname="$$(uname -a)"; \
	if [ "$$(echo "$${_uname}" | grep Darwin)" ]; then \
	  echo 'Hello, macOS!'; \
	  fd ".DS_Store" "$${HOME}" --hidden --no-ignore | xargs -t rm -f; \
	  xattr -rc $(MF_GITHUB_DIR); \
	elif [ "$$(echo "$${_uname}" | grep Ubuntu)" ]; then \
	  echo 'Hello, Ubuntu'; \
	elif [ "$$(echo "$${_uname}" | grep WSL2)" ]; then \
	  echo 'Hello, WSL2!'; \
	elif [ "$$(echo "$${_uname}" | grep arm)" ]; then \
	  echo 'Hello, Raspberry Pi!'; \
	elif [ "$$(echo "$${_uname}" | grep el7)" ]; then \
	  echo 'Hello, CentOS!'; \
	else \
	  echo 'Which OS are you using?'; \
	fi

link:  ## make symbolic links
	# dotfiles
	ln -fs $(MF_DOTFILES_DIR)/dot.config/codex              "$${HOME}"/.codex
	ln -fs $(MF_DOTFILES_DIR)/dot.editorconfig              "$${HOME}"/.editorconfig
	# XDG_CONFIG_HOME
	. $(MF_DOTFILES_DIR)/dot.zshenv \
	&& mkdir -p "$${XDG_CONFIG_HOME}" \
	&& cp -rf $(MF_DOTFILES_DIR)/dot.config/git             "$${XDG_CONFIG_HOME}" \
	&& ln -fs $(MF_DOTFILES_DIR)/dot.config/alacritty       "$${XDG_CONFIG_HOME}" \
	&& ln -fs $(MF_DOTFILES_DIR)/dot.config/claude          "$${XDG_CONFIG_HOME}" \
	&& ln -fs $(MF_DOTFILES_DIR)/dot.config/codex           "$${XDG_CONFIG_HOME}" \
	&& ln -fs $(MF_DOTFILES_DIR)/dot.config/efm-langserver  "$${XDG_CONFIG_HOME}" \
	&& ln -fs $(MF_DOTFILES_DIR)/dot.config/mise            "$${XDG_CONFIG_HOME}" \
	&& ln -fs $(MF_DOTFILES_DIR)/dot.config/nvim/nvim       "$${XDG_CONFIG_HOME}" \
	&& ln -fs $(MF_DOTFILES_DIR)/dot.config/skk             "$${XDG_CONFIG_HOME}" \
	&& ln -fs $(MF_DOTFILES_DIR)/dot.config/tmux            "$${XDG_CONFIG_HOME}" \
	&& ln -fs $(MF_DOTFILES_DIR)/dot.config/vim             "$${XDG_CONFIG_HOME}" \
	&& ln -fs $(MF_DOTFILES_DIR)/dot.config/zeno            "$${XDG_CONFIG_HOME}"
	# OS-specific link
	# VS Code
	_uname="$$(uname -a)"; \
	if [ "$$(echo "$${_uname}" | grep Darwin)" ]; then \
	  _code_setting_dir="$${HOME}""/Library/Application Support/Code/User"; \
	else \
	  _code_setting_dir="$${HOME}"/.vscode-server/data/Machine; \
	fi \
	&& rm -rf "$${_code_setting_dir}"/snippets \
	&& mkdir -p "$${_code_setting_dir}"/snippets \
	&& cp -f $(MF_DOTFILES_DIR)/dot.config/vim/snippet/* "$${_code_setting_dir}"/snippets \
	&& ln -fs $(MF_DOTFILES_DIR)/dot.vscode/settings.json "$${_code_setting_dir}"

unlink:  ## unlink symbolic links
	# dotfiles
	if [ -L "$${HOME}"/.editorconfig ];                 then unlink "$${HOME}"/.editorconfig; fi
	if [ -L "$${HOME}"/.codex ];                        then unlink "$${HOME}"/.codex; fi
	# XDG_CONFIG_HOME
	. $(MF_DOTFILES_DIR)/dot.zshenv \
	&& if [ -L "$${XDG_CONFIG_HOME}"/aerospace ];       then unlink "$${XDG_CONFIG_HOME}"/aerospace; fi \
	&& if [ -L "$${XDG_CONFIG_HOME}"/alacritty ];       then unlink "$${XDG_CONFIG_HOME}"/alacritty; fi \
	&& if [ -L "$${XDG_CONFIG_HOME}"/claude ];          then unlink "$${XDG_CONFIG_HOME}"/claude; fi \
	&& if [ -L "$${XDG_CONFIG_HOME}"/codex ];           then unlink "$${XDG_CONFIG_HOME}"/codex; fi \
	&& if [ -L "$${XDG_CONFIG_HOME}"/efm-langserver ];  then unlink "$${XDG_CONFIG_HOME}"/efm-langserver; fi \
	&& if [ -L "$${XDG_CONFIG_HOME}"/ghostty ];         then unlink "$${XDG_CONFIG_HOME}"/ghostty; fi \
	&& if [ -L "$${XDG_CONFIG_HOME}"/git ];             then unlink "$${XDG_CONFIG_HOME}"/git; fi \
	&& if [ -L "$${XDG_CONFIG_HOME}"/mise ];            then unlink "$${XDG_CONFIG_HOME}"/mise; fi \
	&& if [ -L "$${XDG_CONFIG_HOME}"/nvim ];            then unlink "$${XDG_CONFIG_HOME}"/nvim; fi \
	&& if [ -L "$${XDG_CONFIG_HOME}"/skk ];             then unlink "$${XDG_CONFIG_HOME}"/skk; fi \
	&& if [ -L "$${XDG_CONFIG_HOME}"/tmux ];            then unlink "$${XDG_CONFIG_HOME}"/tmux; fi \
	&& if [ -L "$${XDG_CONFIG_HOME}"/vim ];             then unlink "$${XDG_CONFIG_HOME}"/vim; fi \
	&& if [ -L "$${XDG_CONFIG_HOME}"/zeno ];            then unlink "$${XDG_CONFIG_HOME}"/zeno; fi
	# OS-specific unlink
	_uname="$$(uname -a)"; \
	if [ "$$(echo "$${_uname}" | grep Darwin)" ]; then \
	  _code_setting_dir="$${HOME}""/Library/Application Support/Code/User"; \
	else \
	  _code_setting_dir="$${HOME}"/.vscode-server/data/Machine; \
	fi \
	&& if [ -L "$${_code_setting_dir}"/settings.json ]; then unlink "$${_code_setting_dir}"/settings.json; fi


# --------------------------------------
# macOS Tasks
#
mac-init: common-init mac-alacritty-init  ## init for Mac
	defaults write com.apple.Finder QuitMenuItem -bool YES
	defaults write com.apple.desktopservices DSDontWriteNetworkStores True
	defaults write com.maisin.boost ApplePressAndHoldEnabled -bool false
	defaults write com.maisin.boost.helper ApplePressAndHoldEnabled -bool false
	# normal minimum is 15 (225 ms)
	defaults write -g InitialKeyRepeat -int 15
	# normal minimum is 2 (30 ms)
	defaults write -g KeyRepeat -int 1
	killall Finder > /dev/null 2>&1

define MF_MAC_ALACRITTY
[general]
import = [
    '~/.config/alacritty/common.toml',
    '~/.config/alacritty/macos.toml'
]
endef
export MF_MAC_ALACRITTY

mac-alacritty-init:
	echo "$${MF_MAC_ALACRITTY}" | tee "$${HOME}"/.config/alacritty/alacritty.toml
	. $(MF_DOTFILES_DIR)/dot.zshenv \
	&& git clone https://github.com/alacritty/alacritty-theme "$${XDG_CONFIG_HOME}"/alacritty/themes

mac-vscode-init:
	rm -rf "$${HOME}"/.vscode
	rm -rf "$${HOME}"'/Library/Application Support/Code'


# --------------------------------------
# Ubuntu Tasks
#
ubuntu-server-init: common-init package-ubuntu-server-install  ## init for Ubuntu Server

ubuntu-desktop-init: common-init package-ubuntu-desktop-install ubuntu-alacritty-init  ## init for Ubuntu Desktop

define MF_UBUNTU_ALACRITTY
[general]
import = [
    '~/.config/alacritty/common.toml',
    '~/.config/alacritty/ubuntu.toml'
]
endef
export MF_UBUNTU_ALACRITTY

ubuntu-alacritty-init:
	echo "$${MF_UBUNTU_ALACRITTY}" | tee "$${HOME}"/.config/alacritty/alacritty.toml
	. $(MF_DOTFILES_DIR)/dot.zshenv \
	&& git clone https://github.com/alacritty/alacritty-theme "$${XDG_CONFIG_HOME}"/alacritty/themes


# --------------------------------------
# Windows & WSL Tasks
#
wsl-init: ubuntu-minimal-init win-copy  ## init for WSL2 Ubuntu
	# https://tech-blog.cloud-config.jp/2024-06-18-wsl2-easiest-github-authentication
	sudo apt-get install -y wslu
	# https://thinkit.co.jp/article/37792
	# https://thinkit.co.jp/article/37737
	sudo apt-get install -U -y nautilus
	# https://inno-tech-life.com/dev/infra/wsl2-ssh-agent/
	eval `ssh-agent`
	echo "Restart WSL2"

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
	cp -rf $(MF_DOTFILES_DIR)/bin           $(MF_WIN_UTIL_DIR)
	cp -rf $(MF_DOTFILES_DIR)/dot.config    $(MF_WIN_UTIL_DIR)
	cp -rf $(MF_DOTFILES_DIR)/dot.vscode    $(MF_WIN_UTIL_DIR)
	cp -rf $(MF_DOTFILES_DIR)/etc           $(MF_WIN_UTIL_DIR)
	echo "$${MF_WSLCONFIG_IN_WINDOWS}" | tee $(MF_WIN_UTIL_DIR)/etc/dot.wslconfig


# --------------------------------------
# Package Management
#
package-npm-install:
	npm install -g npm
	npm install -g @aikidosec/safe-chain
	safe-chain setup
	# Other packages
	npm install -g @anthropic-ai/claude-code
	npm install -g @devcontainers/cli
	npm install -g @github/copilot
	npm install -g @google/gemini-cli
	npm install -g @openai/codex
	npm install -g zenn-cli

package-npm-update:
	npm update -g npm
	# Other packages
	npm outdated -g --parseable --depth=0 | cut -d: -f4 | xargs -r npm install -g

package-update:
	# OS common update
	mise self-update --yes
	mise upgrade
	@$(MAKE) package-npm-update
	# OS-specific update
	_uname="$$(uname -a)"; \
	if [ "$$(echo "$${_uname}" | grep Darwin)" ]; then \
	  echo 'Hello, macOS!'; \
	  brew update; \
	  brew upgrade; \
	elif [ "$$(echo "$${_uname}" | grep Ubuntu)" ]; then \
	  echo 'Hello, Ubuntu'; \
	  sudo apt-get update; \
	  sudo apt-get upgrade -y; \
	elif [ "$$(echo "$${_uname}" | grep WSL2)" ]; then \
	  echo 'Hello, WSL2!'; \
	  sudo apt-get update; \
	  sudo apt-get upgrade -y; \
	elif [ "$$(echo "$${_uname}" | grep arm)" ]; then \
	  echo 'Hello, Raspberry Pi!'; \
	elif [ "$$(echo "$${_uname}" | grep el7)" ]; then \
	  echo 'Hello, CentOS!'; \
	else \
	  echo 'Which OS are you using?'; \
	fi

package-install:
	# OS-common install
	# mise
	curl https://mise.run | sh
	"$${HOME}"/.local/bin/mise install
	# OS-specific install
	_uname="$$(uname -a)"; \
	if [ "$$(echo "$${_uname}" | grep Darwin)" ]; then \
	  echo 'Hello, macOS!'; \
	  $(MAKE) package-mac-install; \
	elif [ "$$(echo "$${_uname}" | grep Ubuntu)" ]; then \
	  echo 'Hello, Ubuntu'; \
	  $(MAKE) package-ubuntu-install; \
	elif [ "$$(echo "$${_uname}" | grep WSL2)" ]; then \
	  echo 'Hello, WSL2!'; \
	  $(MAKE) package-ubuntu-install; \
	elif [ "$$(echo "$${_uname}" | grep arm)" ]; then \
	  echo 'Hello, Raspberry Pi!'; \
	elif [ "$$(echo "$${_uname}" | grep el7)" ]; then \
	  echo 'Hello, CentOS!'; \
	else \
	  echo 'Which OS are you using?'; \
	fi
	echo "Restart Shell"

package-mac-install:
	# https://brew.sh/
	/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	# visual-studio-code
	. $(MF_DOTFILES_DIR)/dot.zshenv \
	&& brew -v \
	&& brew update \
	&& brew upgrade \
	&& brew install \
	  alacritty \
	  docker-desktop \
	  font-myricam \
	  google-chrome \
	  openvpn-connect \
	  zoom \
	&& brew install \
	  git \
	  tmux
	# Neovim
	. $(MF_DOTFILES_DIR)/dot.zshenv \
	&& brew install ninja cmake gettext curl git

package-ubuntu-install:
	sudo apt-get install -y zsh
	chsh -s "$$(which zsh)"
	sudo add-apt-repository -y ppa:git-core/ppa
	sudo apt-get update
	sudo apt-get upgrade -y
	sudo apt-get install -y \
	  git \
	  ssh \
	  tmux \
	  unzip \
	  xsel \
	  zip
	# Vim
	sudo sed -i 's/^Types: deb$$/Types: deb deb-src/' /etc/apt/sources.list.d/ubuntu.sources
	sudo apt-get update
	sudo apt-get build-dep -y vim
	# Neovim
	# https://github.com/neovim/neovim/blob/master/BUILD.md
	sudo apt-get install -y \
	  ninja-build gettext cmake unzip curl build-essential
	# tmux
	sudo apt-get install bison

package-ubuntu-server-install:
	sudo apt-get install -y openssh-server
	sudo systemctl daemon-reload
	sudo systemctl start ssh.service
	sudo systemctl enable ssh.service

package-ubuntu-desktop-install:
	# Settings --> Accessibility --> Large Text
	# Alacritty
	sudo add-apt-repository -y ppa:aslatter/ppa
	sudo apt-get update
	sudo apt-get install -y alacritty
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
claude-config:  ## configure Claude Code
	claude config set --global preferredNotifChannel terminal_bell

ghq-get-essential:
	_list_path=$(MF_DOTFILES_DIR)/etc/ghq-list-essential.txt \
	&& [ -f "$${_list_path}" ] && cat "$${_list_path}" | ghq get -p

git-config:
	git config --global color.ui auto
	git config --global commit.gpgsign true
	git config --global commit.verbose true
	git config --global core.autocrlf input
	git config --global core.commentChar ';'
	git config --global core.editor vim
	git config --global core.excludesfile '~/.config/git/ignore'
	git config --global core.ignorecase false
	git config --global core.pager 'LESSCHARSET=utf-8 less'
	git config --global core.quotepath false
	git config --global core.safecrlf true
	git config --global credential.helper store
	git config --global diff.algorithm histogram
	git config --global diff.compactionHeuristic true
	git config --global diff.tool vimdiff
	git config --global difftool.prompt false
	git config --global difftool.vimdiff.path vim
	git config --global fetch.prune true
	git config --global ghq.root '~/ghq'
	git config --global gpg.format ssh
	git config --global grep.lineNumber true
	git config --global http.sslVerify false
	git config --global init.defaultBranch main
	git config --global merge.conflictstyle diff3
	git config --global merge.tool vimdiff
	git config --global mergetool.prompt false
	git config --global mergetool.vimdiff.path vim
	git config --global push.default current
	git config --global user.signingkey '~/.ssh/github.pub'

nvim-build:  ## build Neovim
	# git clean -ffdx
	# $(MAKE) distclean
	# BUNDLED_CMAKE_FLAG='-DUSE_BUNDLED_TS_PARSERS=OFF'
	cd $(MF_GITHUB_DIR)/neovim/neovim \
	&& git fetch --tags --force \
	&& git switch refs/tags/nightly --detach \
	&& $(MAKE) distclean \
	&& $(MAKE) \
	  CMAKE_BUILD_TYPE=Release \
	  CMAKE_INSTALL_PREFIX="$${HOME}"/.local \
	&& $(MAKE) install

tmux-init:
	git clone https://github.com/tmux-plugins/tpm $(MF_DOTFILES_DIR)/dot.config/tmux/plugins/tpm

vim-build:  ## build Vim
	# git clean -ffdx
	# $(MAKE) distclean
	_uname="$$(uname -a)"; \
	if [ "$$(echo "$${_uname}" | grep Darwin)" ]; then \
	  _config_opts="--enable-darwin"; \
	else \
	  _config_opts="--without-x"; \
	fi \
	&& cd $(MF_GITHUB_DIR)/vim/vim \
	&& cd src \
	&& $(MAKE) distclean \
	&& ./configure \
	  "$${_config_opts}" \
	  --disable-gui \
	  --enable-clipboard \
	  --enable-fail-if-missing \
	  --enable-multibyte \
	  --prefix="$${HOME}"/.local \
	  --with-features=huge \
	  --without-wayland \
	&& $(MAKE) \
	&& $(MAKE) install

zinit-install:
	# Zinit
	bash -c "$$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
	zsh -c ". "$${HOME}"/.local/share/zinit/zinit.git/zinit.zsh && zinit self-update"

zsh-init:
	# Zsh
	echo "[ -r $(MF_DOTFILES_DIR)/dot.zshenv ] && . $(MF_DOTFILES_DIR)/dot.zshenv" >> "$${HOME}"/.zshenv
	echo "[ -r $(MF_DOTFILES_DIR)/dot.zshrc ] && . $(MF_DOTFILES_DIR)/dot.zshrc" >> "$${HOME}"/.zshrc
