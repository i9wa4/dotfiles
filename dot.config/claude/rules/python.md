# Python ルール

## 基本ルール

- NEVER: グローバル Python 環境を汚染しない
- NEVER: 勝手に `uv.lock` や `.venv/` を作成しない

## Python 仮想環境の利用方法

### uv.lock がある場合

`uv` を利用して Python コマンドを実行する

```sh
uv run dbt debug --profiles-dir ~/.dbt --no-use-colors
```

### poetry.lock がある場合

以下のブログ記事を参考に `uv` で仮想環境を作成する

- [poetry の pyproject.toml から uv で仮想環境を作成する方法](https://i9wa4.github.io/blog/2025-06-08-create-uv-venv-with-poetry-pyproject-toml.html)

### uv.lock がない場合

1. 仮想環境を有効化する

    ```sh
    source .venv/bin/activate
    ```

2. Python コマンドを実行する

    ```sh
    dbt debug --profiles-dir ~/.dbt --no-use-colors
    ```
