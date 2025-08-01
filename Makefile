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

test:
	@echo "$${PATH}" | tr ':' '\n'
	@echo uname: "$$(uname -a)"
	@echo dotfiles: $(MF_DOTFILES_DIR)
	@echo dotfiles: "$(MF_DOTFILES_DIR)"
	@echo shell: "$$0"
	@echo dot.zshenv load test:
	. $(MF_DOTFILES_DIR)/dot.zshenv


# --------------------------------------
# Global Variables
#
MF_DOTFILES_DIR := "$${HOME}"/ghq/github.com/i9wa4/dotfiles
MF_GITHUB_DIR := "$${HOME}"/ghq/github.com


# --------------------------------------
# OS-common Initialization
#
common-init: zinit-install zsh-init unlink link git-config tmux-init ghq-get-essential
	mkdir -p "$${HOME}"/str/src


# --------------------------------------
# Tasks for macOS
#
mac-init: package-mac-install common-init mac-alacritty-init  ## init for Mac
	defaults write com.apple.Finder QuitMenuItem -bool YES
	defaults write com.apple.desktopservices DSDontWriteNetworkStores True
	defaults write com.maisin.boost ApplePressAndHoldEnabled -bool false
	defaults write com.maisin.boost.helper ApplePressAndHoldEnabled -bool false
	# normal minimum is 15 (225 ms)
	defaults write -g InitialKeyRepeat -int 15
	# normal minimum is 2 (30 ms)
	defaults write -g KeyRepeat -int 1
	killall Finder > /dev/null 2>&1

mac-vscode-init:
	rm -rf "$${HOME}"/.vscode
	rm -rf "$${HOME}"'/Library/Application Support/Code'

mac-vscode-insiders-init:
	rm -rf "$${HOME}"/.vscode-insiders
	rm -rf "$${HOME}"'/Library/Application Support/Code - Insiders'

mac-clean:
	fd ".DS_Store" $(MF_GITHUB_DIR) --hidden --no-ignore | xargs -t rm -f
	xattr -rc $(MF_GITHUB_DIR)
	[ -d "$${HOME}"/str ] && xattr -rc "$${HOME}"/str

mac-copy:
	if [ -L "$${HOME}"'/Google Drive' ]; then \
	  rsync -av --delete "$${HOME}"/str "$${HOME}"'/Google Drive/マイドライブ'; \
	fi

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


# --------------------------------------
# Tasks for Ubuntu
#
ubuntu-minimal-init: package-ubuntu-install common-init

ubuntu-server-init: ubuntu-minimal-init package-ubuntu-server-install  ## init for Ubuntu Server

ubuntu-desktop-init: ubuntu-server-init ubuntu-alacritty-init package-ubuntu-desktop-install  ## init for Ubuntu Desktop

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

ubuntu-awscli-update:
	# AWS CLI
	# https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
	cd \
	&& curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
	&& unzip -fo awscliv2.zip \
	&& sudo ./aws/install --update \
	&& rm awscliv2.zip \


# --------------------------------------
# Tasks for Windows & WSL
#
wsl-init: ubuntu-minimal-init win-copy  ## init for WSL2 Ubuntu
	# https://tech-blog.cloud-config.jp/2024-06-18-wsl2-easiest-github-authentication
	sudo apt install -y wslu
	# https://thinkit.co.jp/article/37792
	# https://thinkit.co.jp/article/37737
	sudo apt install -U -y nautilus
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
# Symbolic Links
#
link:  ## make symbolic links
	# dotfiles
	ln -fs $(MF_DOTFILES_DIR)/dot.editorconfig              "$${HOME}"/.editorconfig
	# XDG_CONFIG_HOME
	. $(MF_DOTFILES_DIR)/dot.zshenv \
	&& mkdir -p "$${XDG_CONFIG_HOME}" \
	&& cp -rf $(MF_DOTFILES_DIR)/dot.config/git             "$${XDG_CONFIG_HOME}" \
	&& ln -fs $(MF_DOTFILES_DIR)/dot.config/aerospace       "$${XDG_CONFIG_HOME}" \
	&& ln -fs $(MF_DOTFILES_DIR)/dot.config/alacritty       "$${XDG_CONFIG_HOME}" \
	&& ln -fs $(MF_DOTFILES_DIR)/dot.config/claude          "$${XDG_CONFIG_HOME}" \
	&& ln -fs $(MF_DOTFILES_DIR)/dot.config/efm-langserver  "$${XDG_CONFIG_HOME}" \
	&& ln -fs $(MF_DOTFILES_DIR)/dot.config/nvim/nvim       "$${XDG_CONFIG_HOME}" \
	&& ln -fs $(MF_DOTFILES_DIR)/dot.config/skk             "$${XDG_CONFIG_HOME}" \
	&& ln -fs $(MF_DOTFILES_DIR)/dot.config/tmux            "$${XDG_CONFIG_HOME}" \
	&& ln -fs $(MF_DOTFILES_DIR)/dot.config/vim             "$${XDG_CONFIG_HOME}" \
	&& ln -fs $(MF_DOTFILES_DIR)/dot.config/zeno            "$${XDG_CONFIG_HOME}"
	# OS-specific link
	_uname="$$(uname -a)"; \
	_code_setting_dir="$${HOME}"/.vscode-server/data/Machine; \
	if [ "$$(echo "$${_uname}" | grep Darwin)" ]; then \
	  echo 'Hello, macOS!'; \
	  $(MAKE) mac-clean; \
	  $(MAKE) mac-copy; \
	  _code_setting_dir="$${HOME}"'/Library/Application Support/Code/User'; \
	elif [ "$$(echo "$${_uname}" | grep Ubuntu)" ]; then \
	  echo 'Hello, Ubuntu'; \
	elif [ "$$(echo "$${_uname}" | grep WSL2)" ]; then \
	  echo 'Hello, WSL2!'; \
	  $(MAKE) win-copy; \
	elif [ "$$(echo "$${_uname}" | grep arm)" ]; then \
	  echo 'Hello, Raspberry Pi!'; \
	elif [ "$$(echo "$${_uname}" | grep el7)" ]; then \
	  echo 'Hello, CentOS!'; \
	else \
	  echo 'Which OS are you using?'; \
	fi \
	&& rm -rf "$${_code_setting_dir}"/snippets \
	&& mkdir -p "$${_code_setting_dir}"/snippets \
	&& cp -f $(MF_DOTFILES_DIR)/dot.config/vim/snippet/* "$${_code_setting_dir}"/snippets \
	&& ln -fs $(MF_DOTFILES_DIR)/dot.vscode/settings.json "$${_code_setting_dir}"
	echo "Remove ~/.gitconfig's core.excludesfile!"


unlink:  ## unlink symbolic links
	# dotfiles
	if [ -L "$${HOME}"/.editorconfig ];                 then unlink "$${HOME}"/.editorconfig; fi
	# XDG_CONFIG_HOME
	. $(MF_DOTFILES_DIR)/dot.zshenv \
	&& if [ -L "$${XDG_CONFIG_HOME}"/aerospace ];       then unlink "$${XDG_CONFIG_HOME}"/aerospace; fi \
	&& if [ -L "$${XDG_CONFIG_HOME}"/alacritty ];       then unlink "$${XDG_CONFIG_HOME}"/alacritty; fi \
	&& if [ -L "$${XDG_CONFIG_HOME}"/claude ];          then unlink "$${XDG_CONFIG_HOME}"/claude; fi \
	&& if [ -L "$${XDG_CONFIG_HOME}"/efm-langserver ];  then unlink "$${XDG_CONFIG_HOME}"/efm-langserver; fi \
	&& if [ -L "$${XDG_CONFIG_HOME}"/ghostty ];         then unlink "$${XDG_CONFIG_HOME}"/ghostty; fi \
	&& if [ -L "$${XDG_CONFIG_HOME}"/git ];             then unlink "$${XDG_CONFIG_HOME}"/git; fi \
	&& if [ -L "$${XDG_CONFIG_HOME}"/nvim ];            then unlink "$${XDG_CONFIG_HOME}"/nvim; fi \
	&& if [ -L "$${XDG_CONFIG_HOME}"/skk ];             then unlink "$${XDG_CONFIG_HOME}"/skk; fi \
	&& if [ -L "$${XDG_CONFIG_HOME}"/tmux ];            then unlink "$${XDG_CONFIG_HOME}"/tmux; fi \
	&& if [ -L "$${XDG_CONFIG_HOME}"/vim ];             then unlink "$${XDG_CONFIG_HOME}"/vim; fi \
	&& if [ -L "$${XDG_CONFIG_HOME}"/zeno ];            then unlink "$${XDG_CONFIG_HOME}"/zeno; fi
	# OS-specific unlink
	_uname="$$(uname -a)"; \
	_code_setting_dir="$${HOME}"/.vscode-server/data/Machine; \
	if [ "$$(echo "$${_uname}" | grep Darwin)" ]; then \
	  echo 'Hello, macOS!'; \
	  _code_setting_dir="$${HOME}""/Library/Application Support/Code/User"; \
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
	fi \
	&& if [ -L "$${_code_setting_dir}"/settings.json ]; then unlink "$${_code_setting_dir}"/settings.json; fi


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

package-npm-install:
	npm install -g @anthropic-ai/claude-code
	npm install -g @devcontainers/cli
	npm install -g @google/gemini-cli

package-npm-update:
	npm update -g @anthropic-ai/claude-code
	npm update -g @devcontainers/cli
	npm update -g @google/gemini-cli

package-rust:
	rustup update
	. $(MF_DOTFILES_DIR)/dot.zshenv \
	&& cargo install --locked --git https://github.com/XAMPPRocky/tokei.git tokei

package-update:
	# OS-specific update
	_uname="$$(uname -a)"; \
	if [ "$$(echo "$${_uname}" | grep Darwin)" ]; then \
	  echo 'Hello, macOS!'; \
	  $(MAKE) package-mac-update; \
	elif [ "$$(echo "$${_uname}" | grep Ubuntu)" ]; then \
	  echo 'Hello, Ubuntu'; \
	  $(MAKE) package-ubuntu-update; \
	elif [ "$$(echo "$${_uname}" | grep WSL2)" ]; then \
	  echo 'Hello, WSL2!'; \
	  $(MAKE) package-ubuntu-update; \
	elif [ "$$(echo "$${_uname}" | grep arm)" ]; then \
	  echo 'Hello, Raspberry Pi!'; \
	elif [ "$$(echo "$${_uname}" | grep el7)" ]; then \
	  echo 'Hello, CentOS!'; \
	else \
	  echo 'Which OS are you using?'; \
	fi
	# OS common update
	@$(MAKE) package-go
	@$(MAKE) package-rust
	@$(MAKE) package-npm-install
	@$(MAKE) package-npm-update
	@$(MAKE) volta-update
	# Deno
	. $(MF_DOTFILES_DIR)/dot.zshenv \
	&& deno upgrade "$${DENO_VER_PATCH}"
	# uv
	uv self update

package-common-install:  ## install common packages
	# Deno
	curl -fsSL https://deno.land/install.sh | sh
	# uv
	curl -LsSf https://astral.sh/uv/install.sh | sh
	# Volta
	curl https://get.volta.sh | bash
	"$${HOME}"/.volta/bin/volta install node
	echo "Restart Shell"

package-mac-install:
	# https://brew.sh/
	/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	# visual-studio-code@insiders
	. $(MF_DOTFILES_DIR)/dot.zshenv \
	&& brew -v \
	&& brew update \
	&& brew upgrade \
	&& brew install \
	  alacritty \
	  cursor \
	  docker \
	  font-myricam \
	  font-noto-sans-jp \
	  google-chrome \
	  google-drive \
	  nikitabobko/tap/aerospace \
	  visual-studio-code \
	  zoom \
	&& brew tap FelixKratz/formulae && brew install borders \
	&& brew install \
	  fd \
	  fzf \
	  gh \
	  git \
	  grep \
	  hadolint \
	  jq \
	  make \
	  nvim \
	  pre-commit \
	  ripgrep \
	  shellcheck \
	  tflint \
	  tmux \
	  vim \
	  wget \
	  zsh \
	&& brew install python-tk@3.12 \
	&& brew tap jameswoolfenden/homebrew-tap && bres install jameswoolfenden/tap/pike \
	&& brew install ninja cmake gettext curl \
	&& brew install go \
	&& brew install rustup-init && rustup-init \
	&& brew install awscli \
	&& brew install google-cloud-sdk \
	&& brew tap databricks/tap && brew install databricks \
	&& brew install openssl readline sqlite3 xz zlib tcl-tk \
	# brew install aws-vpn-client
	# brew install snowflake-snowsql
	# python-tk@3.12 for https://github.com/GongRzhe/Human-In-the-Loop-MCP-Server

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
	sudo sed -i 's/^Types: deb$$/Types: deb deb-src/' /etc/apt/sources.list.d/ubuntu.sources
	sudo apt update
	sudo apt build-dep -y vim
	# Neovim
	# https://github.com/neovim/neovim/blob/master/BUILD.md
	sudo apt install -y \
	  ninja-build gettext cmake unzip curl build-essential
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
	sudo apt install -y \
	  build-essential libssl-dev zlib1g-dev \
	  libbz2-dev libreadline-dev libsqlite3-dev curl git \
	  libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

package-ubuntu-update:
	sudo apt update
	sudo apt upgrade -y

package-ubuntu-server-install:
	sudo apt install -y openssh-server
	sudo systemctl daemon-reload
	sudo systemctl start ssh.service
	sudo systemctl enable ssh.service

package-ubuntu-desktop-install:
	# Settings --> Accessibility --> Large Text
	# Alacritty
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


# --------------------------------------
#  Tools
#
act-install:  ## install act
	ghq get -p nektos/act

act-build:  ## build act
	@$(MAKE) -C $(MF_GITHUB_DIR)/nektos/act build

claude-config:  ## configure Claude Code
	claude config set --global preferredNotifChannel terminal_bell
	claude mcp add -s user "github" -- npx -y @modelcontextprotocol/server-github
	claude mcp add -s user "atlassian" -- npx -y mcp-remote https://mcp.atlassian.com/v1/sse
	claude mcp add -s user "awslabs-aws-documentation-mcp-server" -e FASTMCP_LOG_LEVEL=ERROR -- uvx awslabs.aws-documentation-mcp-server@latest
	claude mcp add -s user "human-in-the-loop" -- uvx hitl-mcp-server
	claude mcp add -s user "context7" -- npx -y @upstash/context7-mcp
	claude mcp add -s user "terraform" -- docker run -i --rm hashicorp/terraform-mcp-server
	claude mcp add -s user "serena" -- uvx --from git+https://github.com/oraios/serena serena-mcp-server --context ide-assistant
	# claude mcp add serena -- uvx --from git+https://github.com/oraios/serena serena-mcp-server --context ide-assistant --project $(pwd)


ghq-get-essential:
	_list_path=$(MF_DOTFILES_DIR)/etc/ghq-list-essential.txt \
	&& [ -f "$${_list_path}" ] && cat "$${_list_path}" | ghq get -p

ghq-get-local:
	. "$${HOME}"/.zshenv \
	&& _list_path="$${XDG_CACHE_HOME}"/ghq-list-local.txt \
	&& [ -f "$${_list_path}" ] && cat "$${_list_path}" | ghq get -p

ghq-backup-local:
	. "$${HOME}"/.zshenv \
	&& _list_path="$${XDG_CACHE_HOME}"/ghq-list-local.txt \
	&& ghq list > "$${_list_path}" \
	&& sort --unique "$${_list_path}" -o "$${_list_path}"

git-config:
	git config --global color.ui auto
	git config --global commit.gpgsign true
	git config --global commit.verbose true
	git config --global core.autocrlf input
	git config --global core.editor vim
	git config --global core.excludesfile '~/.config/git/ignore'
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
	&& git fetch --all \
	&& git switch refs/tags/nightly --detach \
	&& $(MAKE) \
	  CMAKE_BUILD_TYPE=Release \
	  CMAKE_INSTALL_PREFIX="$${HOME}"/.local \
	&& $(MAKE) install

tfenv-terraform-install:  ## install Terraform (e.g. make tfenv-terraform-install TF_VER_PATCH=1.9.3)
	. $(MF_DOTFILES_DIR)/dot.zshenv \
	&& tfenv install "$(TF_VER_PATCH)" \
	&& tfenv use "$(TF_VER_PATCH)" \
	&& terraform version

tfenv-terraform-install-latest:  ## install latest Terraform
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

tmux-init:
	git clone https://github.com/tmux-plugins/tpm $(MF_DOTFILES_DIR)/dot.config/tmux/plugins/tpm

vim-build:  ## build Vim
	# git clean -ffdx
	# $(MAKE) distclean
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
	&& cd $(MF_GITHUB_DIR)/vim/vim \
	&& cd src \
	&& ./configure \
	  --disable-gui \
	  --enable-fail-if-missing \
	  --enable-luainterp=dynamic --with-luajit --with-lua-prefix="$${_lua_prefix}" \
	  --enable-multibyte \
	  --enable-python3interp=dynamic \
	  --prefix="$${HOME}"/.local \
	  --with-features=huge \
	&& $(MAKE) \
	&& $(MAKE) install

volta-update:
	curl https://get.volta.sh | bash

zinit-install:
	# Zinit
	bash -c "$$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
	zsh -c ". "$${HOME}"/.local/share/zinit/zinit.git/zinit.zsh && zinit self-update"

zsh-init:
	# Zsh
	echo "[ -r $(MF_DOTFILES_DIR)/dot.zshenv ] && . $(MF_DOTFILES_DIR)/dot.zshenv" >> "$${HOME}"/.zshenv
	echo "[ -r $(MF_DOTFILES_DIR)/dot.zshrc ] && . $(MF_DOTFILES_DIR)/dot.zshrc" >> "$${HOME}"/.zshrc
