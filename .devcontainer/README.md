# README

## 1. Dev Container GitHub CLI 設定手順

Dev Container内でGitHub CLIを使用するための設定手順です。

### 1.1. 設定方法

1. 現在の gh の認証トークンを確認

    ```sh
    gh auth status --show-token
    ```

2. トークンを取得

    ```sh
    # ~/.zshrc または ~/.bashrc に追加
    export GH_TOKEN="your_github_token_here"
    ```
