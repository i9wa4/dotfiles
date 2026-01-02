# dotfiles

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/i9wa4/dotfiles)

## 1. Target OS

- macOS
- Ubuntu 24.04 LTS
- Ubuntu 24.04 LTS (Windows, WSL2)

## 2. OS-specific Pre Installation

### 2.1. Windows

1. Install WSL2 and Ubuntu.
   - <https://learn.microsoft.com/en-us/windows/wsl/install>
   - <https://i9wa4.github.io/blog/2024-03-25-setup-wsl2.html>
1. Launch Ubuntu with PowerShell.

    ```dosbat
    wsl
    ```

## 3. Installation

1. Establish an SSH connection to GitHub.
   - <https://qiita.com/ucan-lab/items/e02f2d3a35f266631f24>
1. Add the GitHub Signing Keys and Authentication Keys.
   - <https://qiita.com/habu1010/items/dbd59495a68a0b9dc953>
1. Execute a git command to install Command Line Developer Tools.

    ```sh
    git --version
    ```

1. Execute the following command.

    ```sh
    git clone git@github.com:i9wa4/dotfiles ~/ghq/github.com/i9wa4/dotfiles \
    && cd ~/ghq/github.com/i9wa4/dotfiles \
    && _uname="$$(uname -a)"; \
    if [ "$$(echo "$${_uname}" | grep Darwin)" ]; then \
      echo 'Hello, macOS!'; \
      make mac-init; \
    elif [ "$$(echo "$${_uname}" | grep Ubuntu)" ]; then \
      echo 'Hello, Ubuntu'; \
      sudo apt install -y make; \
      make ubuntu-server-init; \
    elif [ "$$(echo "$${_uname}" | grep WSL2)" ]; then \
      echo 'Hello, WSL2!'; \
      sudo apt install -y make; \
      make wsl-init; \
    elif [ "$$(echo "$${_uname}" | grep arm)" ]; then \
      echo 'Hello, Raspberry Pi!'; \
    elif [ "$$(echo "$${_uname}" | grep el7)" ]; then \
      echo 'Hello, CentOS!'; \
    else \
      echo 'Which OS are you using?'; \
    fi
    ```

1. Restart the terminal and execute the following command.

    ```sh
    cd ~/ghq/github.com/i9wa4/dotfiles && make common-package-init
    ```

## 4. OS-specific Post Installation

### 4.1. Windows

1. Run `C:\work\util\bin\win-copy.bat`.
1. Run `C:\work\util\bin\winget-upgrade.bat`.

### 4.2. macOS

[Mac 環境構築手順 – uma-chan’s page](https://i9wa4.github.io/blog/2024-06-17-setup-mac.html)

## 5. OS-common Post Installation

### 5.1. AWS CLI

- Authentication with AWS CLI
    - [Configuring IAM Identity Center authentication with the AWS CLI - AWS Command Line Interface](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html)
- `~/.aws/config`
    - [Configuration and credential file settings in the AWS CLI - AWS Command Line Interface](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
- `~/.aws/credentials`
    - [Authenticating using IAM user credentials for the AWS CLI - AWS Command Line Interface](https://docs.aws.amazon.com/cli/latest/userguide/cli-authentication-user.html)
    - Follow the instroctions of "Access Keys".

### 5.2. gh

1. Choose SSH for Git operation protocol.
1. Skip uploading SSH public key.
1. Login with a web browser: <https://github.com/login/device>.
1. You can use the following command to login with a token.

    ```sh
    gh auth status --show-token | gh auth login --with-token
    ```

### 5.3. Web Browser

#### 5.3.1. Setting Synchronization

- Password: No
- Address: No
- Google Pay: No
- The Others: Yes

#### 5.3.2. Search Engine

- Google Japanese Search
    - `https://www.google.com/search?q=%s`
- Google English Search
    - `https://www.google.com/search?q=%s&gl=us&hl=en&gws_rd=cr&pws=0`
- DuckDuckGo Japanese Search
    - `https://duckduckgo.com/?q=%s&kl=jp-jp&kz=-1&kav=1&kaf=1&k1=-1&ia=web`
- DuckDuckGo English Search
    - `https://duckduckgo.com/?q=%s&kl=us-en&kz=-1&kav=1&kaf=1&k1=-1&ia=web`

#### 5.3.3. Extension

- Flow Chat for YouTube Live
- Okta Browser Plugin

### 5.4. Slack

- GitHub Notifications
    - `/github subscribe owner/repo reviews,comments,branches,commits:*`

### 5.5. SSH Connection to Ubuntu Server

cf. [Linux サーバー：SSH 設定（2024年7月更新）](https://zenn.dev/wsuzume/articles/26b26106c3925e)

1. [Server] Set `PasswordAuthentication yes` in `/etc/ssh/sshd_config`.
1. [Server] Restart ssh.

    ```sh
    [Server] $ sudo systemctl restart ssh.service
    ```
1. Execute the following commands.

    ```sh
    [Client] $ ssh-keygen -t ed25519
    [Client] $ ssh -p port username@192.168.xxx.xxx  # or hostname
    [Server] $ exit
    [Client] $ scp -P port ~/.ssh/id_ed25519.pub username@hostname:~/.ssh/register_key
    [Client] $ ssh -p port username@192.168.xxx.xxx
    [Server] $ cd ~/.ssh
    [Server] $ cat register_key >> authorized_keys
    [Server] $ chmod 600 authorized_keys
    [Server] $ rm register_key
    ```

1. [Server] Set `PasswordAuthentication no` in `/etc/ssh/sshd_config`.
1. [Server] Restart ssh.

    ```sh
    [Server] $ sudo systemctl restart ssh.service
    ```

1. [Client] Configure `~/.ssh/config`

    ```sh
    Host sandbox
        HostName        192.168.xxx.xxx
        Port            port
        IdentityFile    ~/.ssh/id_ed25519
        User            username
    ```

## 6. Python Virtual Environment Update

1. Update `.python-version` or `pyproject.toml` as needed.
1. Update `uv.lock`.

    ```sh
    uv lock --upgrade
    ```

1. Update .venv.

    ```sh
    uv sync --frozen
    # or
    uv sync --frozen --group dev
    ```

## 7. nix-darwin (macOS)

cf. <https://github.com/i9wa4/dotfiles/issues/69>

### 7.1. Install Nix

> The only prerequisite is a Nix implementation
>
> -- [nix-darwin README](https://github.com/nix-darwin/nix-darwin)

```sh
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)
```

cf. [Nix Official Download](https://nixos.org/download/)

### 7.2. Setup nix-darwin and home-manager

> outputsにdarwinConfigurations.\<host\>に対して構成を定義でき、`sudo darwin-rebuild switch --flake ".#<host>"`コマンドを利用して適用できます。
>
> -- [2025年のdotfiles](https://zenn.dev/momeemt/articles/dotfiles2025)

```sh
# 1. Create user.nix from template (contains username, not committed to git)
cp user.nix.example user.nix
# Edit user.nix and set your username

# 2. Backup existing shell configs (first time only)
#    nix-darwin will fail if /etc/bashrc or /etc/zshrc exist with unrecognized content.
#    The error message instructs to rename them with .before-nix-darwin suffix.
#    cf. https://github.com/nix-darwin/nix-darwin/issues/149
sudo mv /etc/bashrc /etc/bashrc.before-nix-darwin
sudo mv /etc/zshrc /etc/zshrc.before-nix-darwin

# 3. Initial installation
#    --impure: required to read user.nix (not tracked by git)
#    --no-update-lock-file: use existing flake.lock (reproducible)
sudo nix --extra-experimental-features 'nix-command flakes' run nix-darwin -- switch --flake '.#macos-p' --impure --no-update-lock-file

# 4. Open a new terminal (darwin-rebuild is now in PATH)

# 5. Subsequent updates
sudo darwin-rebuild switch --flake '.#macos-p' --impure
```

cf.

- [nix-darwin README](https://github.com/nix-darwin/nix-darwin)
- [home-manager Manual](https://nix-community.github.io/home-manager/)
- [nix-darwin issue 149: Allow enforcing linking etc when file exists](https://github.com/nix-darwin/nix-darwin/issues/149)
- [2025年のdotfiles](https://zenn.dev/momeemt/articles/dotfiles2025)
- [Homebrew管理下のGUIもNixに移してみる nix-darwin篇](https://zenn.dev/kawarimidoll/articles/271c339c5392ce)
