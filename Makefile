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
MF_GITHUB_DIR := $(shell ghq root)/github.com
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
nix-flake-update:  ## upgrade all packages in nix profile
	nix flake update

nix-profile:  ## nix profile
	nix profile add github:numtide/llm-agents.nix#ccusage
	nix profile add github:numtide/llm-agents.nix#ccusage-codex
	nix profile add github:numtide/llm-agents.nix#coderabbit-cli
	nix profile add github:numtide/llm-agents.nix#codex
	nix profile add github:numtide/llm-agents.nix#copilot-cli
	nix profile add github:numtide/llm-agents.nix#goose-cli
	# https://github.com/ryoppippi/claude-code-overlay/commits/main/
	# nix profile add github:ryoppippi/claude-code-overlay#claude
	nix profile remove claude
	nix profile add github:ryoppippi/claude-code-overlay/4a1d2830d097ea2a10ea6ba391df7a2c83f1a3f8#claude  # 2.1.16
	nix profile upgrade --all

nix-switch:  ## update ghq repos and switch nix configuration
ifeq ($(MF_DETECTED_OS),macOS)
	@profile=$$(echo -e "macos-p\nmacos-w" | fzf --prompt="Select profile: ") && \
	sudo darwin-rebuild switch --impure --flake ".#$${profile}"
endif
	uv run python bin/nix-flake-diff.py

# nvim-build:  ## build Neovim from source
# 	ghq get -p neovim/neovim
# 	cd $(MF_GITHUB_DIR)/neovim/neovim && \
# 	make distclean || true && \
# 	make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX="$${HOME}"/.local && \
# 	make install && \
# 	rm -rf build

# vim-build:  ## build Vim from source
# 	ghq get -p vim/vim
# ifeq ($(MF_DETECTED_OS),macOS)
# 	cd $(MF_GITHUB_DIR)/vim/vim/src && \
# 	make distclean || true && \
# 	./configure \
# 		--disable-gui \
# 		--enable-clipboard \
# 		--enable-darwin \
# 		--enable-fail-if-missing \
# 		--enable-multibyte \
# 		--prefix="$${HOME}"/.local \
# 		--with-features=huge \
# 		--without-wayland && \
# 	make && \
# 	make install
# else
# 	cd $(MF_GITHUB_DIR)/vim/vim/src && \
# 	make distclean || true && \
# 	./configure \
# 		--disable-gui \
# 		--enable-clipboard \
# 		--enable-fail-if-missing \
# 		--enable-multibyte \
# 		--prefix="$${HOME}"/.local \
# 		--with-features=huge \
# 		--without-x \
# 		--without-wayland && \
# 	make && \
# 	make install
# endif


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
	echo "$${MF_WSLCONFIG_IN_WINDOWS}" | \
		tee $(MF_WIN_UTIL_DIR)/etc/dot.wslconfig
	rm -rf $(MF_WIN_UTIL_DIR)
	cp -rf $(MF_GITHUB_DIR)/i9wa4/dotfiles/bin $(MF_WIN_UTIL_DIR)
