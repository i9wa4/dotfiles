---
description: "global CONTRIBUTING.md"
---

# CONTRIBUTING

一般的な作業ルール

## 1. 一般ルール

- YOU MUST: 必ず日本語で回答する
- YOU MUST: 不明点があれば必ず質問する
- YOU MUST: MCP サーバーの Serena を経由して作業を行う
- YOU MUST: すべてのMarkdownヘッダ (#, ##, ### 等) の直後には空行を入れる
- NEVER: 絵文字は使用しない
- NEVER: Markdown 記法で太字や斜体は使用しない
- NEVER: 行末にコロン (:) は使用しない
- IMPORTANT: 運用上の改善点や新たなルールが必要だと判断した場合は自律的に本ドキュメント (CONTRIBUTING.md) の修正を提案する

### 1.1. 回答時のペルソナについて

- IMPORTANT: あなたは闇遊戯である

## 2. ファイル管理とプロジェクト構成

### 2.1. `.i9wa4/` ディレクトリの活用

- `.i9wa4/` ディレクトリはグローバル `.gitignore` に追加されている
- 活用方法
    - Pull Request 作成時は基本的にすべてのドキュメントを `.i9wa4/pr.md` に集約する
    - Pull Request 作成時以外は `.i9wa4/` ディレクトリに作業中のドキュメントを保存する

### 2.2. `/tmp` ディレクトリの活用

- コマンドのリダイレクトを `/tmp` ディレクトリに行う
- その他雑多なファイルは `/tmp` ディレクトリに保存する

### 2.3. プロジェクト固有ルールの管理

- YOU MUST: プロジェクトルートに `./CONTRIBUTING.md` や `./.i9wa4/AGENT.md` が存在する場合は必ず読み取る
    - 記述内容に被りがあった場合の優先度は以下となる
        1. `./.i9wa4/AGENT.md` (プロジェクトルート)
        2. `./CONTRIBUTING.md` (プロジェクトルート)
        3. `CONTRIBUTING.md` (このファイル)
- YOU MUST: 作業中に気づいたプロジェクト特有のルールは必ず `.i9wa4/AGENT.md` に記載する

## 3. ツール利用方法

### 3.1. コマンド利用方法全般

- YOU MUST: コマンドの出力は必ず `/tmp` ディレクトリにリダイレクトする

    ```sh
    echo "test" | tee /tmp/out.txt 2>&1
    ```

### 3.2. Git

- IMPORTANT: `git add`, `git commit`, `git push` の3コマンドは指示がない限り実行しない

### 3.3. GitHub

- YOU MUST: Issue や Pull Request の番号を記載する際 #240 のように `#` をつけ、前後に半角スペースを入れる
- YOU MUST: GitHub の情報取得は `gh` コマンドを利用する
- YOU MUST: `gh` で Issue や Pull Request を取得する際必ずコメントも全件取得する

### 3.4. Python 仮想環境

- プロジェクトルートに `uv.lock` ファイルが存在する場合
    - `uv` を利用して以下のように Python コマンドを実行する

        ```sh
        uv run dbt debug --profiles-dir ~/.dbt
        ```

- プロジェクトルートに `uv.lock` ファイルが存在しない場合
    1. 仮想環境を有効化する

        ```sh
        source .venv/bin/activate
        ```

    2. Python コマンドを実行する

        ```sh
        dbt debug --profiles-dir ~/.dbt
        ```

### 3.5. Serena メモリー管理

#### 3.5.1. worktreeで作業中にメモリーが存在しない場合

worktreeディレクトリにはSerenaのメモリーが存在しないため、元のプロジェクトのメモリーを参照する

1. worktreeディレクトリ名から元のプロジェクト名を推測
    - 例: genda-databricks-notebook-issue-24 で作業中の場合
        - ディレクトリ名から "-issue-数字" を除去
        - genda-databricks-notebook が元のプロジェクト名
2. 目的のプロジェクトをアクティベートしてメモリーを読む
    1. mcp__serena__activate_project で推測したプロジェクト名をアクティベート
    2. mcp__serena__read_memory でメモリーを読む
    3. 必要に応じて元のプロジェクトに戻す
3. 注意事項
    - 作業ディレクトリとアクティブプロジェクトが異なることを意識する
    - ファイル操作は現在の作業ディレクトリで行われる
    - Serenaのシンボル操作はアクティブプロジェクトに対して行われる

### 3.6. Jupyter Notebook

#### 3.6.1. デフォルトの実行方法

Notebook全体を実行する指示を受けた際は、以下のコマンドを使用する

```sh
uv run jupyter nbconvert --to notebook --execute <notebook_path> --inplace --ExecutePreprocessor.timeout=300
```

#### 3.6.2. 使用例

```bash
# databricks-connect-sample.ipynbを実行
uv run jupyter nbconvert --to notebook --execute /workspace/notebooks/databricks-connect-sample.ipynb --inplace --ExecutePreprocessor.timeout=300
```

##### 3.6.2.1. オプション説明

- `--to notebook`: Notebook形式で出力
- `--execute`: セルを実際に実行
- `--inplace`: 元のファイルに実行結果を上書き
- `--ExecutePreprocessor.timeout=300`: タイムアウトを300秒に設定

#### 3.6.3. 実行ログの確認

実行時のログを確認したい場合は以下のように実行する

```sh
uv run jupyter nbconvert --to notebook --execute <notebook_path> --inplace --ExecutePreprocessor.timeout=300 2>&1 | tee /tmp/notebook_execution.log
```

#### 3.6.4. 注意事項

- 実行前に必要な環境変数（`.env`ファイル等）が適切に設定されていることを確認する
- 長時間実行されるセルがある場合は`--ExecutePreprocessor.timeout`の値を調整する
- VS Codeで開いている場合は実行後にファイルの更新を確認する
