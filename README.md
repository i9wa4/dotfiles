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
    $ gh auth status --show-token | gh auth login --with-token
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
- Markdown Preview Plus
- Slack Channels Grouping

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
    $ uv lock --upgrade
    ```

1. Update .venv.

    ```sh
    $ uv sync --frozen
    # or
    $ uv sync --frozen --group dev
    ```
