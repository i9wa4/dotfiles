# dotfiles

## 1. Installation

1. Clone this repository.

    ```sh
    cd && git clone https://github.com/i9wa4/dotfiles
    ```

### 1.1. WSL2 (Ubuntu 24.04)

1. Install WSL2 and Ubuntu 24.04.
    - <https://learn.microsoft.com/en-us/windows/wsl/install>
    - <https://i9wa4.github.io/blog/posts/2024-03-25-setup-wsl2.html>
1. Install make.

    ```sh
    sudo apt install -y make
    ```

1. Execute the following command.

    ```sh
    make wsl2
    ```

1. Install Alacritty.

    ```powershell
    winget install Alacritty.Alacritty
    ```

### 1.2. Ubuntu 24.04

1. Execute the following command.

    ```sh
    make ubuntu
    ```

### 1.3. Mac

1. Execute the following command.

    ```sh
    make mac
    ```

## 2. Post installation

### 2.1. AWS CLI

<https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html>
