# dotfiles

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
1. Add the GitHub Signing Key.
    - <https://qiita.com/habu1010/items/dbd59495a68a0b9dc953>
1. Execute the following command.

    ```sh
    git clone git@github.com:i9wa4/dotfiles ~/src/github.com/i9wa4/dotfiles \
    && cd ~/src/github.com/i9wa4/dotfiles \
    && _uname="$$(uname -a)"; \
    if [ "$$(echo "$${_uname}" | grep Darwin)" ]; then \
      echo 'Hello, macOS!'; \
      make mac; \
    elif [ "$$(echo "$${_uname}" | grep Ubuntu)" ]; then \
      echo 'Hello, Ubuntu'; \
      sudo apt install -y make; \
      make ubuntu; \
    elif [ "$$(echo "$${_uname}" | grep WSL2)" ]; then \
      echo 'Hello, WSL2!'; \
      sudo apt install -y make; \
      make wsl2; \
    elif [ "$$(echo "$${_uname}" | grep arm)" ]; then \
      echo 'Hello, Raspberry Pi!'; \
    elif [ "$$(echo "$${_uname}" | grep el7)" ]; then \
      echo 'Hello, CentOS!'; \
    else \
      echo 'Which OS are you using?'; \
    fi
    ```

## 4. OS-specific Post Installation

### 4.1. Windows

1. Run `C:\work\util\bin\win-copy.bat`.
1. Run `C:\work\util\bin\winget-upgrade.bat`.

### 4.2. CorvusSKK

1. Install CorvusSKK.
    - <https://github.com/nathancorvussolis/corvusskk>
1. Enable the Dictionaries.
    - `%APPDATA%\CorvusSKK`
1. Configure sticky shift.
    - "設定" --> "キー1" --> "変換位置": ";"

### 4.3. macOS

#### 4.3.1. macSKK

1. Enable the Dictionaries.

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

### 5.3. Arc

#### 5.3.1. Search Engine

- Google Japanese Search
    - `https://www.google.com/search?q=%s`
- Google English Search
    - `https://www.google.com/search?q=%s&gl=us&hl=en&gws_rd=cr&pws=0`
- DuckDuckGo Japanese Search
    - `https://duckduckgo.com/?q=%s&kl=jp-jp&kz=-1&kav=1&kaf=1&k1=-1&ia=web`
- DuckDuckGo English Search
    - `https://duckduckgo.com/?q=%s&kl=us-en&kz=-1&kav=1&kaf=1&k1=-1&ia=web`
