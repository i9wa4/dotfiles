.PHONY: minimal
minimal: init copy apt git \
	vim-init vim-build

.PHONY: wsl
wsl: minimal \
	win-copy \
	docker-init \
	prompt-restart-wsl

.PHONY: ubuntu
wsl: minimal \
	docker-init docker-systemd

.PHONY: ubuntu-desktop
ubuntu-desktop: minimal \
	docker-init docker-systemd \
	ubuntu-server



.PHONY: prompt-restart-wsl
prompt-restart-wsl:
	echo "Restart WSL and execute 'make docker-systemd'"



.PHONY: init
init:
	# Bash
	echo "if [ -f "$${HOME}"/dotfiles/etc/dot.bashrc ]; then . "$${HOME}"/dotfiles/etc/dot.bashrc; fi" >> "$${HOME}"/.bashrc
	echo "cd" >> "$${HOME}"/.bashrc
	echo "if [ -f "$${HOME}"/dotfiles/etc/dot.profile ]; then . "$${HOME}"/dotfiles/etc/dot.profile; fi" >> "$${HOME}"/.profile

.PHONY: copy
copy:
	# dotfiles
	# cp -rf "$${HOME}"/dotfiles/etc/home/dot.markdownlint-cli2.jsonc "$${HOME}"/.markdownlint-cli2.jsonc
	cp -rf "$${HOME}"/dotfiles/etc/home/dot.bash_profile "$${HOME}"/.bash_profile
	cp -rf "$${HOME}"/dotfiles/etc/home/dot.gitignore "$${HOME}"/.gitignore
	cp -rf "$${HOME}"/dotfiles/etc/home/dot.jupytext "$${HOME}"/.jupytext
	cp -rf "$${HOME}"/dotfiles/etc/home/dot.tmux.conf "$${HOME}"/.tmux.conf
	# Vim (symbolic link)
	rm -f "$${HOME}"/.vimrc
	rm -rf "$${HOME}"/.vim
	ln -fs "$${HOME}"/dotfiles/dot.vim "$${HOME}"/.vim
	# Neovim (symbolic link)
	. "$${HOME}"/.profile \
	&& mkdir -p "$${XDG_CONFIG_HOME}" \
	&& rm -rf "$${XDG_CONFIG_HOME}"/"$${NVIM_APPNAME1}" \
	&& rm -rf "$${XDG_CONFIG_HOME}"/"$${NVIM_APPNAME2}" \
	&& ln -fs "$${HOME}"/dotfiles/dot.nvim/"$${NVIM_APPNAME1}" "$${XDG_CONFIG_HOME}"/"$${NVIM_APPNAME1}" \
	&& ln -fs "$${HOME}"/dotfiles/dot.nvim/"$${NVIM_APPNAME2}" "$${XDG_CONFIG_HOME}"/"$${NVIM_APPNAME2}"

.PHONY: win-copy
WIN_UTIL_DIR := /mnt/c/work/util
win-copy:
	# WSL
	sudo cp -f "$${HOME}"/dotfiles/etc/wsl/wsl.conf /etc/wsl.conf
	# Windows symbolic link
	mkdir -p /mnt/c/work
	# rm -rf "$${HOME}"/work
	# ln -s /mnt/c/work/ "$${HOME}"/work
	# Windows copy
	rm -rf "$(WIN_UTIL_DIR)"
	mkdir -p "$(WIN_UTIL_DIR)"
	cp -f "$${HOME}"/dotfiles/bin/windows/my_copy.bat "$(WIN_UTIL_DIR)"
	cp -rf "$${HOME}"/dotfiles/bin "$(WIN_UTIL_DIR)"
	cp -rf "$${HOME}"/dotfiles/dot.jupyter "$(WIN_UTIL_DIR)"
	cp -rf "$${HOME}"/dotfiles/dot.nvim "$(WIN_UTIL_DIR)"
	cp -rf "$${HOME}"/dotfiles/dot.vim "$(WIN_UTIL_DIR)"
	cp -rf "$${HOME}"/dotfiles/etc "$(WIN_UTIL_DIR)"

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
	  shellcheck \
	  tmux \
	  unzip \
	  vim \
	  xsel \
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
	# Deno
	if [ -z "$$(which deno)" ]; then curl -fsSL https://deno.land/install.sh | bash; fi
	# SKK
	mkdir -p "$${HOME}"/.skk
	cd "$${HOME}"/.skk \
	&& wget http://openlab.jp/skk/dic/SKK-JISYO.L.gz \
	&& gzip -d SKK-JISYO.L.gz \
	&& wget http://openlab.jp/skk/dic/SKK-JISYO.jinmei.gz \
	&& gzip -d SKK-JISYO.jinmei.gz

.PHONY: vim-build
vim-build:
	cd /usr/local/src/vim \
	&& sudo git checkout master \
	&& sudo git fetch \
	&& sudo git merge \
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
	cd /usr/local/src \
	&& if [ ! -d ./neovim ]; then sudo git clone https://github.com/neovim/neovim.git; fi

.PHONY: nvim-build
nvim-build:
	cd /usr/local/src/neovim \
	&& sudo git checkout master \
	&& sudo git fetch \
	&& sudo git merge \
	&& sudo make CMAKE_BUILD_TYPE=Release \
	&& sudo make install

.PHONY: anaconda-init
anaconda-init:
	cd \
	&& wget https://repo.anaconda.com/archive/Anaconda3-2023.07-2-Linux-x86_64.sh \
	&& bash Anaconda3-2023.07-2-Linux-x86_64.sh
	. "$${HOME}"/.bashrc \
	&& conda config --append channels conda-forge \
	&& conda config --set auto_activate_base false \
	&& conda update --all \
	&& conda info -e
	# conda env create -y -f foo.yml

.PHONY: docker-init
docker-init:
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

.PHONY: docker-hadolint
docker-hadolint:
	sudo curl -L https://github.com/hadolint/hadolint/releases/download/v2.12.0/hadolint-Linux-x86_64 -o /usr/local/bin/hadolint
	sudo chmod 755 /usr/local/bin/hadolint

.PHONY: docker-systemd
docker-systemd:
	sudo systemctl daemon-reload
	sudo systemctl start docker
	sudo systemctl enable docker

.PHONY: docker-trivy
docker-trivy:
	# https://aquasecurity.github.io/trivy/v0.45/getting-started/installation/
	sudo apt-get install wget apt-transport-https gnupg lsb-release
	wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
	echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb "$$(lsb_release -sc) main"" | sudo tee -a /etc/apt/sources.list.d/trivy.list
	sudo apt-get update
	sudo apt-get install trivy

.PHONY: go-init
go-init:
	sudo add-apt-repository -y ppa:longsleep/golang-backports
	sudo apt update
	sudo apt install -y golang-go
	go install github.com/rhysd/vim-startuptime@latest
	# $$ vim-startuptime -vimpath nvim -count 1000
	# $$ vim-startuptime -vimpath vim -count 1000

.PHONY: jekyll-init
jekyll-init:
	# https://maeda577.github.io/2019/11/04/new-jekyll.html
	# https://github.com/github/pages-gem
	sudo apt update
	sudo apt upgrade -y
	sudo apt install -y ruby ruby-bundler
	. "$${HOME}"/.profile \
	&& gem install bundler --user-install

.PHONY: nodejs-init
nodejs-init:
	# Node.js/npm
	# https://github.com/nodesource/distributions/blob/master/README.md#debinstall
	# https://github.com/nodesource/distributions/issues/1157
	sudo rm -f /etc/apt/sources.list.d/nodesource.list
	curl -fsSL https://deb.nodesource.com/setup_19.x | sudo -E bash -
	sudo apt update
	sudo apt install -y nodejs

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

.PHONY: ubuntu-server
ubuntu-server:
	# Settings --> Accessibility --> Large Text
	# https://askubuntu.com/questions/1456119/no-wifi-and-display-brightness-options-after-removing-nvidia-graphics-drivers
	sudo apt install -y --reinstall linux-generic-hwe-22.04
	# https://zenn.dev/wsuzume/articles/26b26106c3925e
	sudo apt install -y openssh-server
	sudo systemctl daemon-reload
	sudo systemctl enable ssh.service
	sudo systemctl start ssh.service
