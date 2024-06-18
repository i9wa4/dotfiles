# dotfiles

## 1. Requirements

- make

## 2. Installation

### 2.1. WSL2 (Ubuntu)

1. Install Alacritty.
    - `winget install Alacritty.Alacritty`
1. Install WSL2.
    - cf. <https://learn.microsoft.com/en-us/windows/wsl/install>
1. Clone this repository.

    ```sh
    cd && git clone https://github.com/i9wa4/dotfiles
    ```

1. Execute `make init-zsh-ubuntu`.
1. Restart WSL2.

    ```sh
    exit
    ```

    ```powershell
    wsl --shutdown
    wsl
    ```

1. Execute `make wsl2`.
1. (Optional) Install VS Code extension "Remote Development".
    - cf. <https://learn.microsoft.com/en-us/windows/wsl/tutorials/wsl-vscode>

### 2.2. Ubuntu

1. Execute `make init-zsh-ubuntu`.
1. Restart Ubuntu.
1. Execute `make ubuntu`.

### 2.3. Mac

1. Execute `make mac`.

## 3. AWS CLI

cf. <https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html>
