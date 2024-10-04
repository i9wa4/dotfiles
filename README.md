# dotfiles

## 1. Target OS

- macOS
- Ubuntu 24.04 LTS
- Ubuntu 24.04 LTS (WSL2)

## 2. Installation

1. Establish an SSH connection to GitHub.
    - <https://qiita.com/ucan-lab/items/e02f2d3a35f266631f24>
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

1. Run `C:\work\util\win-copy.bat`.

1. Run `C:\work\util\bin\winget-upgrade.bat`.

## 3. Post installation

### 3.1. GitHub signing key

- <https://qiita.com/habu1010/items/dbd59495a68a0b9dc953>

### 3.2. gh

1. Choose SSH for Git operation protocol.
1. Skip uploading SSH public key.
1. Login with a web browser: <https://github.com/login/device>.

### 3.3. AWS CLI

- <https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html>
