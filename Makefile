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

MF_WIN_UTIL_DIR := /mnt/c/work/util


# --------------------------------------
# Utility Tasks
#
clean:  ## clean temporary files
	# OS-common clean
	rm -rf "$${HOME}"/.npm
ifeq ($(MF_DETECTED_OS),macOS)
	# macOS-specific clean
	fd ".DS_Store" $(MF_GITHUB_DIR) --hidden --no-ignore | xargs -t rm -f
	xattr -rc $(MF_GITHUB_DIR)
endif

claude-config:  ## configure Claude Code MCP
	claude mcp add --scope user codex-mcp codex mcp-server

nvim-build:  ## build Neovim from source
	cd $(MF_GITHUB_DIR)/neovim/neovim && \
	make distclean || true && \
	make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX="$${HOME}"/.local && \
	make install && \
	rm -rf build

vim-build:  ## build Vim from source
ifeq ($(MF_DETECTED_OS),macOS)
	cd $(MF_GITHUB_DIR)/vim/vim/src && \
	make distclean || true && \
	./configure \
		--enable-darwin \
		--disable-gui \
		--enable-clipboard \
		--enable-fail-if-missing \
		--enable-multibyte \
		--prefix="$${HOME}"/.local \
		--with-features=huge \
		--without-wayland && \
	make && \
	make install
else
	cd $(MF_GITHUB_DIR)/vim/vim/src && \
	make distclean || true && \
	./configure \
		--without-x \
		--disable-gui \
		--enable-clipboard \
		--enable-fail-if-missing \
		--enable-multibyte \
		--prefix="$${HOME}"/.local \
		--with-features=huge \
		--without-wayland && \
	make && \
	make install
endif


# --------------------------------------
# Linux Tasks (requires sudo)
#
ubuntu-server-init:  ## init for Ubuntu Server (after home-manager switch)
	sudo apt-get install -y openssh-server
	sudo systemctl daemon-reload
	sudo systemctl start ssh.service
	sudo systemctl enable ssh.service


# --------------------------------------
# WSL Tasks (Windows integration)
#
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

win-copy:  ## copy config files for Windows (WSL only)
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
