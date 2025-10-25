# [タスク・ランナーとしてのMake \#Makefile - Qiita](https://qiita.com/shakiyam/items/cdd3c11eba978202a628)
SHELL := /bin/bash
.SHELLFLAGS := -o errexit -o nounset -o pipefail -c
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
efm-langserver      efm-langserver
mise                mise
nvim/nvim           nvim
skk                 skk
tmux                tmux
vim                 vim
zeno                zeno
endef
export MF_LINK_XDG_ROWS

MF_WIN_UTIL_DIR := /mnt/c/work/util
MF_GHQ_LIST_ESSENTIAL := $(MF_DOTFILES_DIR)/etc/ghq-list-essential.txt

define ensure_line_in_file
	grep -qxF "$(1)" "$(2)" 2>/dev/null || echo "$(1)" >> "$(2)"
endef


# --------------------------------------
# OS-common Tasks
#
common-init: zsh-init unlink link git-config package-install ghq-get-essential
	git clone https://github.com/alacritty/alacritty-theme \
		$(MF_DOTFILES_DIR)/dot.config/alacritty/themes
	git clone https://github.com/tmux-plugins/tpm \
		$(MF_DOTFILES_DIR)/dot.config/tmux/plugins/tpm

common-clean:  ## clean for all OS
	# OS-common clean
	rm -rf "$${HOME}"/.npm
ifeq ($(MF_DETECTED_OS),macOS)
	# OS-specific clean
	fd ".DS_Store" $(MF_GITHUB_DIR) --hidden --no-ignore | xargs -t rm -f
	xattr -rc $(MF_GITHUB_DIR)
endif

link:  ## make symbolic links
	# create $$HOME-level symlinks defined in MF_LINK_HOME_ROWS
	printf '%s\n' "$${MF_LINK_HOME_ROWS}" | while read -r src dst; do \
		[ -z "$$src" ] && continue; \
		ln -fsh "$(MF_DOTFILES_DIR)/$$src" "$${HOME}/$$dst"; \
	done
	# ensure XDG_CONFIG_HOME exists and seed git configuration
	. $(MF_DOTFILES_DIR)/dot.zshenv
	# ensure XDG_CONFIG_HOME exists and seed git configuration
	mkdir -p "$${XDG_CONFIG_HOME}"
	cp -rf $(MF_DOTFILES_DIR)/dot.config/git "$${XDG_CONFIG_HOME}"
	# create XDG_CONFIG_HOME symlinks listed in MF_LINK_XDG_ROWS
	printf '%s\n' "$${MF_LINK_XDG_ROWS}" | while read -r src dst; do \
		[ -z "$$src" ] && continue; \
		ln -fsh "$(MF_DOTFILES_DIR)/dot.config/$$src" \
		"$${XDG_CONFIG_HOME}/$$dst"; \
	done
	# refresh Codex CLI configuration and VS Code assets
	[ -r "$(MF_DOTFILES_DIR)/dot.config/codex/generate-config.sh" ] && \
		bash $(MF_DOTFILES_DIR)/dot.config/codex/generate-config.sh
	rm -rf "$(MF_CODE_SETTING_DIR)/snippets"
	mkdir -p "$(MF_CODE_SETTING_DIR)/snippets"
	cp -f $(MF_DOTFILES_DIR)/dot.config/vim/snippet/* \
		"$(MF_CODE_SETTING_DIR)/snippets"
	ln -fsh $(MF_DOTFILES_DIR)/dot.vscode/settings.json \
		"$(MF_CODE_SETTING_DIR)"

unlink:	## unlink symbolic links
	# remove the $$HOME-level symlinks created by link
	printf '%s\n' "$${MF_LINK_HOME_ROWS}" | while read -r _ dst; do \
		[ -z "$$dst" ] && continue; \
		if [ -L "$${HOME}/$$dst" ]; then \
			unlink "$${HOME}/$$dst"; \
		fi; \
	done
	# remove the XDG_CONFIG_HOME symlinks created by link
	. $(MF_DOTFILES_DIR)/dot.zshenv
	printf '%s\n' "$${MF_LINK_XDG_ROWS}" | while read -r _ dst; do \
		[ -z "$$dst" ] && continue; \
		if [ -L "$${XDG_CONFIG_HOME}/$$dst" ]; then \
			unlink "$${XDG_CONFIG_HOME}/$$dst"; \
		fi; \
	done
	# drop the VS Code settings link if present
	if [ -L "$(MF_CODE_SETTING_DIR)/settings.json" ]; then \
		unlink "$(MF_CODE_SETTING_DIR)/settings.json"; \
	fi


# --------------------------------------
# macOS Tasks
#
define MF_MAC_ALACRITTY
[general]
import = [
    '~/.config/alacritty/common.toml',
    '~/.config/alacritty/macos.toml'
]
endef
export MF_MAC_ALACRITTY

mac-init: common-init  ## init for Mac
	echo "$${MF_MAC_ALACRITTY}" | tee "$${HOME}"/.config/alacritty/alacritty.toml
	defaults write com.apple.Finder QuitMenuItem -bool YES
	defaults write com.apple.desktopservices DSDontWriteNetworkStores True
	defaults write com.maisin.boost ApplePressAndHoldEnabled -bool false
	defaults write com.maisin.boost.helper ApplePressAndHoldEnabled -bool false
	# normal minimum is 15 (225 ms)
	defaults write -g InitialKeyRepeat -int 15
	# normal minimum is 2 (30 ms)
	defaults write -g KeyRepeat -int 1
	killall Finder > /dev/null 2>&1


# --------------------------------------
# Ubuntu Tasks
#
ubuntu-server-init: common-init  ## init for Ubuntu Server
	sudo apt-get install -y openssh-server
	sudo systemctl daemon-reload
	sudo systemctl start ssh.service
	sudo systemctl enable ssh.service


# --------------------------------------
# Windows & WSL Tasks
#
wsl-init: common-init win-copy  ## init for WSL2 Ubuntu
	# https://tech-blog.cloud-config.jp/2024-06-18-wsl2-easiest-github-authentication
	sudo apt-get install -y wslu
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

win-copy:  ## copy config files for Windows
	# WSL2
	echo "$${MF_WSLCONF_IN_WSL}" | sudo tee /etc/wsl.conf
	# Windows
	rm -rf $(MF_WIN_UTIL_DIR)
	cp -rf $(MF_DOTFILES_DIR)/bin           $(MF_WIN_UTIL_DIR)
	cp -rf $(MF_DOTFILES_DIR)/dot.config    $(MF_WIN_UTIL_DIR)
	cp -rf $(MF_DOTFILES_DIR)/dot.vscode    $(MF_WIN_UTIL_DIR)
	cp -rf $(MF_DOTFILES_DIR)/etc           $(MF_WIN_UTIL_DIR)
	echo "$${MF_WSLCONFIG_IN_WINDOWS}" | \
		tee $(MF_WIN_UTIL_DIR)/etc/dot.wslconfig


# --------------------------------------
# Package Management
#
package-npm-install:
	npm install -g npm
	npm install -g @aikidosec/safe-chain
	if grep -qF "source ~/.safe-chain/scripts/init-posix.sh" "$${HOME}/.zshrc"; then \
		echo "safe-chain is already configured in ~/.zshrc, skipping setup"; \
	else \
		safe-chain setup; \
	fi
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
	npm outdated -g --parseable --depth=0 \
		| cut -d: -f4 | xargs -r npm install -g

package-install:
	# OS-common install
	# mise
	curl https://mise.run | sh
	"$${HOME}"/.local/bin/mise install
	# OS-specific install
ifeq ($(MF_DETECTED_OS),macOS)
	# https://brew.sh/
	/bin/bash -c \
		"$$(curl -fsSL \
		https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	# NOTE: Load .zshenv to get expected PATH
	. $(MF_DOTFILES_DIR)/dot.zshenv
	brew -v
	brew update
	brew upgrade
	brew install \
		alacritty \
		docker-desktop \
		font-myricam \
		google-chrome \
		openvpn-connect \
		visual-studio-code \
		zoom \
	brew install \
		git \
		tmux
	# Neovim
	brew install ninja cmake gettext curl git
else ifneq ($(filter $(MF_DETECTED_OS),Ubuntu WSL2),)
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
	sudo sed -i \
		's/^Types: deb$$/Types: deb deb-src/' \
		/etc/apt/sources.list.d/ubuntu.sources
	sudo apt-get update
	sudo apt-get build-dep -y vim
	# Neovim
	# https://github.com/neovim/neovim/blob/master/BUILD.md
	sudo apt-get install -y \
		ninja-build gettext cmake unzip curl build-essential
endif
	echo "Restart Shell"

package-update:
	# OS common update
	mise self-update --yes
	mise upgrade
	@$(MAKE) package-npm-install
	@$(MAKE) package-npm-update
	# OS-specific update
ifeq ($(MF_DETECTED_OS),macOS)
	brew update
	brew upgrade
else ifneq ($(filter $(MF_DETECTED_OS),Ubuntu WSL2),)
	sudo apt-get update
	sudo apt-get upgrade -y
endif


# --------------------------------------
#  Tools
#
claude-config:  ## configure Claude Code
	claude config set --global preferredNotifChannel terminal_bell

ghq-get-essential:
	if [ -f "$(MF_GHQ_LIST_ESSENTIAL)" ]; then \
		ghq get -p < "$(MF_GHQ_LIST_ESSENTIAL)"; \
	fi

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
	cd $(MF_GITHUB_DIR)/neovim/neovim && \
	$(MAKE) distclean || true && \
	$(MAKE) CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX="$${HOME}"/.local && \
	$(MAKE) install

vim-build:  ## build Vim
	cd $(MF_GITHUB_DIR)/vim/vim/src && \
	$(MAKE) distclean || true && \
	./configure \
		$(MF_VIM_CONFIG_OPTS) \
		--disable-gui \
		--enable-clipboard \
		--enable-fail-if-missing \
		--enable-multibyte \
		--prefix="$${HOME}"/.local \
		--with-features=huge \
		--without-wayland && \
	$(MAKE) && \
	$(MAKE) install

zsh-init:
	# Zsh
	$(call ensure_line_in_file,[ -r $(MF_DOTFILES_DIR)/dot.zshenv ] && \
		. $(MF_DOTFILES_DIR)/dot.zshenv,$${HOME}/.zshenv)
	$(call ensure_line_in_file,[ -r $(MF_DOTFILES_DIR)/dot.zshrc ] && \
		. $(MF_DOTFILES_DIR)/dot.zshrc,$${HOME}/.zshrc)
