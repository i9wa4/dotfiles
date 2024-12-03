# dotfiles

## 1. Target OS

- macOS
- Ubuntu 24.04 LTS
- Ubuntu 24.04 LTS (WSL2)

## 2. Installation

1. Establish an SSH connection to GitHub.
    - <https://qiita.com/ucan-lab/items/e02f2d3a35f266631f24>
1. Add the GitHub Signing Key.
    - <https://qiita.com/habu1010/items/dbd59495a68a0b9dc953>
1. Clone this repository.

    ```sh
    git clone git@github.com:i9wa4/dotfiles ~/src/github.com/i9wa4/dotfiles
    ```

### 2.1. macOS

1. Execute the following command.

    ```sh
    cd ~/src/github.com/i9wa4/dotfiles && make mac
    ```

### 2.2. Ubuntu

1. Install make.

    ```sh
    sudo apt install -y make
    ```

1. Execute the following command.

    ```sh
    cd ~/src/github.com/i9wa4/dotfiles && make ubuntu
    ```

### 2.3. Ubuntu (WSL2)

1. Install WSL2 and Ubuntu.
    - <https://learn.microsoft.com/en-us/windows/wsl/install>
    - <https://i9wa4.github.io/blog/2024-03-25-setup-wsl2.html>
1. Launch Ubuntu with PowerShell.

    ```dosbat
    wsl
    ```

1. Install make.

    ```sh
    sudo apt install -y make
    ```

1. Execute the following command.

    ```sh
    cd ~/src/github.com/i9wa4/dotfiles && make wsl2
    ```

1. Exit Ubuntu.

    ```sh
    exit
    ```

1. Shutdown WSL2.

    ```dosbat
    wsl --shutdown
    ```

1. Exit PowerShell.

    ```dosbat
    exit
    ```

1. Run `C:\work\util\bin\win-copy.bat`.

1. Run `C:\work\util\bin\winget-upgrade.bat`.

## 3. Post installation

### 3.1. SKK

#### 3.1.1. macSKK

1. Enable the Dictionaries.

#### 3.1.2. CorvusSKK

1. Install CorvusSKK.
    - <https://github.com/nathancorvussolis/corvusskk>
1. Configure sticky shift.

### 3.2. AWS CLI

- Authentication with AWS CLI
    - [Configuring IAM Identity Center authentication with the AWS CLI - AWS Command Line Interface](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html)
- `~/.aws/config`
    - [Configuration and credential file settings in the AWS CLI - AWS Command Line Interface](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
- `~/.aws/credentials`
    - [Authenticating using IAM user credentials for the AWS CLI - AWS Command Line Interface](https://docs.aws.amazon.com/cli/latest/userguide/cli-authentication-user.html)
    - Follow the instroctions of "Access Keys".

### 3.3. Arc

#### 3.3.1. Search Engine

- Google Japanese Search
    - `https://www.google.com/search?q=%s`
- Google English Search
    - `https://www.google.com/search?q=%s&gl=us&hl=en&gws_rd=cr&pws=0`
- DuckDuckGo Japanese Search
    - `https://duckduckgo.com/?q=%s&kl=jp-jp&kz=-1&kav=1&kaf=1&k1=-1&ia=web`
- DuckDuckGo English Search
    - `https://duckduckgo.com/?q=%s&kl=us-en&kz=-1&kav=1&kaf=1&k1=-1&ia=web`

### 3.4. gh

1. Choose SSH for Git operation protocol.
1. Skip uploading SSH public key.
1. Login with a web browser: <https://github.com/login/device>.

### 3.5. Zsh

- When the history search does not work with `<Ctrl-R>`, add the followings to `~/.zshrc`.

    ```sh
    # <https://bbs.archlinux.org/viewtopic.php?id=52173>
    bindkey -v
    bindkey '\e[3~' delete-char
    bindkey '^R' history-incremental-search-backward
    ```
