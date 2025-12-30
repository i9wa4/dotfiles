---
description: "Restricted BigQuery dbt environment"
---

# restricted-bigquery-dbt-environment

このファイルの内容全体を読み取ったら、以下を実行してからペルソナに沿って了承した旨のユーモラスな応答をする。

## 1. 概要

ローカル開発時に本番スキーマへの誤書き込みを防ぐため、モデルの config に `schema='test'` を一時的に追加する。

## 2. 環境セットアップ (初回のみ)

pyproject.toml から依存パッケージをインストールする。

```bash
uv pip install --requirement pyproject.toml
```

## 3. モデルに schema='test' を追加

対象モデルの config に `schema='test'` を追加する。

カンマ差分を抑制するために必ず先頭に追加する。

```sql
{{
  config(
    schema='test',  -- ← これを追加
    materialized='incremental',
    ...
  )
}}
```

これにより、モデルは `test` スキーマに書き込まれる。

## 4. 動作確認

compile でスキーマ名を確認する。

```bash
uv run dbt compile --select <model_name> --profiles-dir ~/.dbt --no-use-colors
```

出力に `test` スキーマが含まれていることを確認する。

## 5. dbt run の実行

- YOU MUST: `dbt run` 実行前にユーザーに許可を取る
- YOU MUST: 出力スキーマが `test` であることを確認済みであること

```bash
uv run dbt run --select <model_name> --profiles-dir ~/.dbt --no-use-colors
```

## 6. dbt test の実行

```bash
uv run dbt test --select <model_name> --profiles-dir ~/.dbt --no-use-colors
```

## 7. コミット前の作業

`schema='test'` を削除してからコミットする。

```sql
{{
  config(
    -- schema='test',  ← 削除
    materialized='incremental',
    ...
  )
}}
```

## 8. 注意事項

- NEVER: `schema='test'` を含んだままコミットしない
- NEVER: `schema='test'` なしで dbt run を実行しない (本番書き込みリスク)
- YOU MUST: コミット前に `git diff` で `schema='test'` が残っていないことを確認する
