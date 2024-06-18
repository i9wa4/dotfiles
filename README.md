# dotfiles

## 1. Target OS

- macOS
- Ubuntu 24.04 LTS
- Ubuntu 24.04 LTS (WSL2)

## 2. Installation

1. Clone this repository.

    ```sh
    cd && git clone https://github.com/i9wa4/dotfiles
    ```

### 2.3. macOS

1. Execute the following command.

    ```sh
    make mac
    ```

### 2.2. Ubuntu

1. Execute the following command.

    ```sh
    make ubuntu
    ```

### 2.1. Ubuntu (WSL2)

1. Install WSL2 and Ubuntu.
    - <https://learn.microsoft.com/en-us/windows/wsl/install>
    - <https://i9wa4.github.io/blog/posts/2024-03-25-setup-wsl2.html>
1. Launch Ubuntu with PowerShell.

    ```powershell
    wsl
    ```

1. Install make.

    ```sh
    sudo apt install -y make
    ```

1. Execute the following command.

    ```sh
    make wsl2
    ```

1. Exit Ubuntu.

    ```sh
    exit
    ```

1. Restart WSL2.

    ```powershell
    wsl --shutdown
    wsl
    ```

1. (Optional) Install Alacritty with PowerShell.

    ```powershell
    winget install Alacritty.Alacritty
    ```

## 3. Post installation

### 3.1. AWS CLI

<https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html>
