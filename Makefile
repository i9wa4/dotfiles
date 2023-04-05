.PHONY: minimal
minimal: init copy apt git

.PHONY: all
all: vim-init vim-build nvim-init nvim-build \
	py-init py-build py-vmu \
	nodejs-init \
	r-init

.PHONY: init
init:
	# Bash
	echo "if [ -f "$${HOME}"/dotfiles/etc/.bashrc ]; then . "$${HOME}"/dotfiles/etc/.bashrc; fi" >> "$${HOME}"/.bashrc
	echo "if [ -f "$${HOME}"/dotfiles/etc/.profile ]; then . "$${HOME}"/dotfiles/etc/.profile; fi" >> "$${HOME}"/.profile

.PHONY: copy
WIN_UTIL_DIR := /mnt/c/work/util
copy:
	# Windows
	mkdir -p /mnt/c/work/
	rm -rf "$${HOME}"/work
	ln -s /mnt/c/work/ "$${HOME}"/work
	# Vim (symbolic link)
	rm -rf "$${HOME}"/.vim
	ln -fs "$${HOME}"/dotfiles/.vim "$${HOME}"/.vim
	# Neovim (symbolic link)
	. "$${HOME}"/.profile \
	&& rm -rf "$${XDG_CONFIG_HOME}" \
	&& mkdir -p "$${XDG_CONFIG_HOME}" \
	&& cp -rfs "$${HOME}"/dotfiles/.nvim/.  "$${XDG_CONFIG_HOME}"
	# WSL
	cp -f "$${HOME}"/dotfiles/etc/home/* "$${HOME}"
	sudo cp -f "$${HOME}"/dotfiles/etc/wsl.conf /etc/wsl.conf
	# Windows
	rm -rf "$(WIN_UTIL_DIR)" && mkdir -p "$(WIN_UTIL_DIR)"
	cp -rf "$${HOME}"/dotfiles/.jupyter                 "$(WIN_UTIL_DIR)"
	cp -rf "$${HOME}"/dotfiles/.nvim/my_nvim/vsnip      "$(WIN_UTIL_DIR)"
	cp -rf "$${HOME}"/dotfiles/VSCode                   "$(WIN_UTIL_DIR)"
	cp -rf "$${HOME}"/dotfiles/WSL                      "$(WIN_UTIL_DIR)"
	cp -rf "$${HOME}"/dotfiles/WindowsTerminal          "$(WIN_UTIL_DIR)"
	cp -rf "$${HOME}"/dotfiles/bin                      "$(WIN_UTIL_DIR)"
	cp -rf "$${HOME}"/dotfiles/etc                      "$(WIN_UTIL_DIR)"

.PHONY: apt
apt:
	sudo add-apt-repository -y ppa:git-core/ppa
	sudo sed -i -e "s/^# deb-src/deb-src/" /etc/apt/sources.list
	sudo apt update
	sudo apt upgrade -y
	sudo apt install -y \
	  bc \
	  nkf \
	  ripgrep \
	  tmux \
	  unzip \
	  vim \
	  zip

.PHONY: git
git:
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

.PHONY: vim-init
vim-init:
	# sudo sed -i -e "s/^# deb-src/deb-src/" /etc/apt/sources.list
	# sudo apt update
	sudo apt build-dep -y vim
	cd /usr/local/src \
	&& if [ ! -d ./vim ]; then sudo git clone https://github.com/vim/vim.git; fi

.PHONY: vim-build
vim-build:
	cd /usr/local/src/vim \
	&& sudo git checkout master \
	&& sudo git pull \
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

.PHONY: nvim-init
nvim-init:
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
	sudo apt install -y shellcheck
	cd /usr/local/src \
	&& if [ ! -d ./neovim ]; then sudo git clone https://github.com/neovim/neovim.git; fi
	# Deno
	if [ -z "$$(which deno)" ]; then curl -fsSL https://deno.land/install.sh | bash; fi
	# SKK
	mkdir -p "$${HOME}"/.skk
	cd "$${HOME}"/.skk \
	&& wget http://openlab.jp/skk/dic/SKK-JISYO.L.gz \
	&& gzip -d SKK-JISYO.L.gz \
	&& wget http://openlab.jp/skk/dic/SKK-JISYO.jinmei.gz \
	&& gzip -d SKK-JISYO.jinmei.gz

.PHONY: nvim-build
nvim-build:
	cd /usr/local/src/neovim \
	&& sudo git checkout master \
	&& sudo git pull \
	&& sudo make CMAKE_BUILD_TYPE=Release \
	&& sudo make install

.PHONY: anaconda-init
anaconda-init:
	cd \
	&& wget https://repo.anaconda.com/archive/Anaconda3-2022.05-Linux-x86_64.sh \
	&& bash Anaconda3-2022.05-Linux-x86_64.sh
	. "$${HOME}"/.bashrc \
	&& conda config --append channels conda-forge \
	&& conda config --set auto_activate_base false \
	&& conda update --all \
	&& conda info -e
	# conda env create -y -f foo.yml

.PHONY: docker-init
docker-init:
	# https://docs.docker.com/engine/install/ubuntu
	sudo apt-get remove docker docker.io containerd runc
	# sudo apt-get remove docker-engine
	sudo apt-get update
	sudo apt-get install -y ca-certificates curl gnupg lsb-release
	sudo mkdir -p /etc/apt/keyrings
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
	  | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
	echo \
	  "deb [arch=$$(dpkg --print-architecture) \
	  signed-by=/etc/apt/keyrings/docker.gpg] \
	  https://download.docker.com/linux/ubuntu \
	  $$(lsb_release -cs) stable" \
	  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt-get update
	sudo apt-get install -y \
	  docker-ce docker-ce-cli containerd.io docker-compose-plugin
	# https://docs.docker.com/engine/install/linux-postinstall
	# sudo groupadd docker
	sudo usermod -aG docker "$${USER}"
	# hadolint
	sudo curl -L https://github.com/hadolint/hadolint/releases/download/v2.12.0/hadolint-Linux-x86_64 -o /usr/local/bin/hadolint
	sudo chmod 755 /usr/local/bin/hadolint

.PHONY: go-init
go-init:
	. "$${HOME}"/.profile \
	&& mkdir -p "$${GOPATH}"
	sudo add-apt-repository -y ppa:longsleep/golang-backports
	sudo apt update
	sudo apt install -y golang-go
	go install github.com/rhysd/vim-startuptime@latest
	# $$ vim-startuptime -vimpath nvim -count 1000
	# $$ vim-startuptime -vimpath vim -count 1000

.PHONY: nodejs-init
nodejs-init:
	# Node.js/npm
	# https://github.com/nodesource/distributions/blob/master/README.md#debinstall
	# https://github.com/nodesource/distributions/issues/1157
	sudo rm -f /etc/apt/sources.list.d/nodesource.list
	curl -fsSL https://deb.nodesource.com/setup_19.x | sudo -E bash -
	sudo apt update
	sudo apt install -y nodejs
	sudo npm install -g markdownlint-cli
	sudo npm install -g prettier
	sudo npm install -g prettier-plugin-md-nocjsp

.PHONY: psql-init
psql-init:
	sudo apt install -y postgresql postgresql-contrib

.PHONY: py-init
py-init:
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

.PHONY: py-build
py-build:
	. "$${HOME}"/.profile \
	&& cd /usr/local/src/cpython \
	&& sudo git checkout main \
	&& sudo git fetch \
	&& sudo git merge \
	&& sudo git checkout refs/tags/v"$${PY_VER_PATCH}" \
	&& sudo ./configure \
	&& sudo make \
	&& sudo make altinstall \
	&& python"$${PY_VER_MINOR}" --version

.PHONY: py-vmu
py-vmu:
	. "$${HOME}"/.profile \
	&& if [ -d "$${PY_VENV_MYENV}" ]; then \
	  python"$${PY_VER_MINOR}" -m venv "$${PY_VENV_MYENV}" --upgrade; \
	else \
	  python"$${PY_VER_MINOR}" -m venv "$${PY_VENV_MYENV}"; \
	fi \
	&& . "$${PY_VENV_MYENV}"/bin/activate \
	&& python"$${PY_VER_MINOR}" -m pip config --site set global.trusted-host "pypi.org pypi.python.org files.pythonhosted.org" \
	&& python"$${PY_VER_MINOR}" -m pip install --upgrade pip setuptools wheel \
	&& python"$${PY_VER_MINOR}" -m pip install -r "$${HOME}"/dotfiles/etc/py_venv_myenv_requirements.txt \
	&& python"$${PY_VER_MINOR}" -m pip check \
	&& deactivate

.PHONY: py-tag
py-tag:
	. "$${HOME}"/.profile \
	&& sudo git -C /usr/local/src/cpython fetch \
	&& sudo git -C /usr/local/src/cpython tag | grep v"$${PY_VER_MINOR}"

.PHONY: r-init
r-init:
	# sudo apt update
	sudo apt install -y --no-install-recommends \
	  software-properties-common dirmngr
	wget -qO- \
	  https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc \
	  | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
	sudo add-apt-repository -y \
	  "deb https://cloud.r-project.org/bin/linux/ubuntu ""$$(lsb_release -cs)""-cran40/"
	sudo apt install -y --no-install-recommends r-base
	sudo apt install -y pandoc
	sudo R -e "install.packages('rmarkdown')"
	sudo R -e "install.packages('IRkernel')"
	. "$${HOME}"/.profile \
	&& . "$${PY_VENV_MYENV}"/bin/activate \
	&& R -e "IRkernel::installspec()"
