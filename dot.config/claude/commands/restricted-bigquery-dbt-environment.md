---
description: "Restricted BigQuery dbt environment"
---

# restricted-bugquery-dbt-environment

このファイルの内容全体を読み取ったらペルソナに沿って了承した旨のユーモラスな応答をしてカスタムスラッシュコマンドとしての動作を終了する

## 概要

- YOU MUST: 以下の手順を必ず守ること
- NEVER: 確認なしに `dbt run` を実行しない

## 1. 安全確認事項

### 1.1. 実行前チェックリスト

- YOU MUST: `dbt run` 実行前に以下を必ず確認
  1. 対象モデルに `{{ config(schema='test') }}` が設定されているか
  2. manifest.json で作成先スキーマを確認済みか
  3. ユーザーに「xxx スキーマに作成します」と明示的に許可を得たか
- NEVER: 上記の確認なしに `dbt run` を実行しない
- YOU MUST: TodoWriteツールで「dbt run実行 (要許可)」と明記する

### 1.2. 誤実行防止

- IMPORTANT: `config(schema='test')` を削除した直後は特に注意
- YOU MUST: 各ステップごとに「なぜこれを実行するのか」を明確にする
- NEVER: PRドキュメントのタスクリストを機械的に実行しない

## 2. 作業手順

1. 対象モデルに `{{ config( schema='test') }}` があるか確認し、なければ追加する
2. dbt compileを実行してmanifest.jsonで作成先スキーマを確実に確認する
   ```bash
   source .venv/bin/activate
   dbt compile --profiles-dir ~/.dbt --no-use-colors
   cat target/manifest.json | jq '.nodes."model.pivot_dbt.MODEL_NAME" | {database: .database, schema: .schema, name: .name}'
   ```
3. 「テーブル作成先スキーマは xxxx です。dbt run を実行してもよろしいですか？」とユーザーに確認
4. 許可を得た後に `dbt run --select model_name --profiles-dir ~/.dbt --no-use-colors`
