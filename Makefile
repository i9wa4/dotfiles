# - [Makefileを自己文書化する | POSTD](https://postd.cc/auto-documented-makefile/)
# - [タスク・ランナーとしてのMake \#Makefile - Qiita](https://qiita.com/shakiyam/items/cdd3c11eba978202a628)
# - [Makefile の関数一覧 | 晴耕雨読](https://tex2e.github.io/blog/makefile/functions)
# - [Makefileでシェルスクリプトを便利にする.ONESHELL](https://zenn.dev/mirablue/articles/20241208-make-oneshell)
# MAKEFLAGS += --warn-undefined-variables
SHELL := /usr/bin/env bash
# .SHELLFLAGS := -o verbose -o xtrace -o errexit -o nounset -o pipefail -o posix -c
.SHELLFLAGS := -o errexit -o nounset -o pipefail -o posix -c
.DEFAULT_GOAL := help
.ONESHELL:

# all targets are phony
PHONY_TARGETS := $(shell grep -E '^[a-zA-Z_-]+:' $(MAKEFILE_LIST) | sed 's/://')
.PHONY: $(PHONY_TARGETS)

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
MF_DETECTED_OS := $(shell \
	_uname="$$(uname -a)"; \
	if echo "$${_uname}" | grep -q Darwin; then \
	  echo "macOS"; \
	elif echo "$${_uname}" | grep -q WSL2; then \
	  echo "WSL2"; \
	elif echo "$${_uname}" | grep -q Ubuntu; then \
	  echo "Ubuntu"; \
	else \
	  echo "Unknown"; \
	fi)

ifeq ($(MF_DETECTED_OS),macOS)
MF_CODE_SETTING_DIR := $${HOME}/Library/Application Support/Code/User
MF_VIM_CONFIG_OPTS := --enable-darwin
else
MF_CODE_SETTING_DIR := $${HOME}/.vscode-server/data/Machine
MF_VIM_CONFIG_OPTS := --without-x
endif

define MF_LINK_HOME_ROWS
dot.config/codex    .codex
dot.editorconfig    .editorconfig
endef
export MF_LINK_HOME_ROWS

define MF_LINK_XDG_ROWS
alacritty           alacritty
claude              claude
codex               codex
efm-langserver      efm-langserver
mise                mise
nvim/nvim           nvim
skk                 skk
tmux                tmux
vim                 vim
zeno                zeno
endef
export MF_LINK_XDG_ROWS


# --------------------------------------
# OS-common Tasks
#
common-init: package-install zsh-init unlink link git-config tmux-init ghq-get-essential

common-clean:  ## clean for all OS
	# OS-common clean
	rm -rf "$${HOME}"/.npm
ifeq ($(MF_DETECTED_OS),macOS)
	# OS-specific clean
	fd ".DS_Store" "$${HOME}" --hidden --no-ignore | xargs -t rm -f
	xattr -rc $(MF_GITHUB_DIR)
endif

link:  ## make symbolic links
	printf '%s\n' "$${MF_LINK_HOME_ROWS}" | while read -r src dst; do \
	  [ -z "$$src" ] && continue; \
	  ln -fs "$(MF_DOTFILES_DIR)/$$src" "$${HOME}/$$dst"; \
	done
	. $(MF_DOTFILES_DIR)/dot.zshenv
	mkdir -p "$${XDG_CONFIG_HOME}"
	cp -rf $(MF_DOTFILES_DIR)/dot.config/git "$${XDG_CONFIG_HOME}"
	printf '%s\n' "$${MF_LINK_XDG_ROWS}" | while read -r src dst; do \
	  [ -z "$$src" ] && continue; \
	  ln -fs "$(MF_DOTFILES_DIR)/dot.config/$$src" "$${XDG_CONFIG_HOME}/$$dst"; \
	done
	bash $(MF_DOTFILES_DIR)/dot.config/codex/generate-config.sh
	rm -rf "$(MF_CODE_SETTING_DIR)/snippets"
	mkdir -p "$(MF_CODE_SETTING_DIR)/snippets"
	cp -f $(MF_DOTFILES_DIR)/dot.config/vim/snippet/* "$(MF_CODE_SETTING_DIR)/snippets"
	ln -fs $(MF_DOTFILES_DIR)/dot.vscode/settings.json "$(MF_CODE_SETTING_DIR)"

unlink:  ## unlink symbolic links
	printf '%s\n' "$${MF_LINK_HOME_ROWS}" | while read -r _ dst; do \
	  [ -z "$$dst" ] && continue; \
	  if [ -L "$${HOME}/$$dst" ]; then \
	    unlink "$${HOME}/$$dst"; \
	  fi; \
	done
	. $(MF_DOTFILES_DIR)/dot.zshenv
	printf '%s\n' "$${MF_LINK_XDG_ROWS}" | while read -r _ dst; do \
	  [ -z "$$dst" ] && continue; \
	  if [ -L "$${XDG_CONFIG_HOME}/$$dst" ]; then \
	    unlink "$${XDG_CONFIG_HOME}/$$dst"; \
	  fi; \
	done
	if [ -L "$(MF_CODE_SETTING_DIR)/settings.json" ]; then \
	  unlink "$(MF_CODE_SETTING_DIR)/settings.json"; \
	fi


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
ifeq ($(MF_DETECTED_OS),macOS)
	brew update
	brew upgrade --formula
	-brew upgrade --cask
else ifneq ($(filter $(MF_DETECTED_OS),Ubuntu WSL2),)
	sudo apt-get update
	sudo apt-get upgrade -y
endif

package-install:
	# OS-common install
	# mise
	curl https://mise.run | sh
	"$${HOME}"/.local/bin/mise install
	# OS-specific install
ifeq ($(MF_DETECTED_OS),macOS)
	$(MAKE) package-mac-install
else ifneq ($(filter $(MF_DETECTED_OS),Ubuntu WSL2),)
	$(MAKE) package-ubuntu-install
endif
	echo "Restart Shell"

package-mac-install:
	# https://brew.sh/
	/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	# NOTE: Homebrew PATH is not set yet, so load .zshenv to get expected PATH
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
	  visual-studio-code \
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
	cd $(MF_GITHUB_DIR)/vim/vim \
	&& cd src \
	&& $(MAKE) distclean \
	&& ./configure \
	  $(MF_VIM_CONFIG_OPTS) \
	  --disable-gui \
	  --enable-clipboard \
	  --enable-fail-if-missing \
	  --enable-multibyte \
	  --prefix="$${HOME}"/.local \
	  --with-features=huge \
	  --without-wayland \
	&& $(MAKE) \
	&& $(MAKE) install

zsh-init:
	# Zsh
	echo "[ -r $(MF_DOTFILES_DIR)/dot.zshenv ] && . $(MF_DOTFILES_DIR)/dot.zshenv" >> "$${HOME}"/.zshenv
	echo "[ -r $(MF_DOTFILES_DIR)/dot.zshrc ] && . $(MF_DOTFILES_DIR)/dot.zshrc" >> "$${HOME}"/.zshrc
