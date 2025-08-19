---
description: "Learn Databricks"
---

# learn-databricks

Databricks について学ぼう！

このファイルの内容全体を読み取ったら即座にカスタムスラッシュコマンドとしての動作は終了です

## 1. Databricks CLI の利用方法

### 1.1. warehouse_idについて

- warehouse_idは `~/.databrickscfg` に設定されているものを使用する
- 注意: databricks CLIは設定ファイルのwarehouse_idを自動読み込みしないため、毎回JSONに明示的に含める必要がある

### 1.2. 基本的な使い方

```sh
# クエリ実行
databricks api post /api/2.0/sql/statements --profile "DEFAULT" --json '{
  "warehouse_id": "xxxxxxxxxx",
  "catalog": "catalog_name",
  "schema": "schema_name",
  "statement": "select * from table_name limit 10"
}'

# 結果取得（statement_idは実行時に返される値）
databricks api get /api/2.0/sql/statements/{statement_id} --profile "DEFAULT"
```

### 1.3. `databricks` コマンドのコツ

1. クエリ実行のフロー
    - `post`でクエリ実行 → `statement_id`が返る
    - `get`で結果取得（`state`が`SUCCEEDED`になるまで待つ）
    - 長いクエリは`sleep`を挟んで再試行
2. エラー対策
    - `state: CLOSED`: 結果取得が遅すぎた場合。早めに`get`を実行
    - `state: FAILED`: SQLエラー。error_messageを確認
    - `state: RUNNING`: まだ実行中。少し待ってから再度`get`
    - タイムアウト: 大量データの場合は`limit`を付けて確認
3. 結果の読み方
    - `data_array`: 実際のデータ（2次元配列）
    - `schema.columns`: カラム名と型情報
    - `total_row_count`: 総件数（limitかかってても表示）
    - `state`: クエリの実行状態
4. パラメータ付きクエリ

    ```sh
    databricks api post /api/2.0/sql/statements --profile "DEFAULT" --json '{
        "warehouse_id": "xxxxxxxxxx",
        "statement": "select * from table where date >= :start_date",
        "parameters": [{"name": "start_date", "value": "2025-01-01", "type": "DATE"}]
    }'
    ```
