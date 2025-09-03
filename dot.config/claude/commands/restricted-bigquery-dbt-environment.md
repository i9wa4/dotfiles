---
description: "Restricted BigQuery dbt environment"
---

# restricted-bugquery-dbt-environment

- YOU MUST: 以下の手順を必ず守ること

## 1. 作業手順

1. 対象モデルに `{{ config( schema='test') }}` があるか確認し、なければ追加する
2. dbt compileを実行してmanifest.jsonで作成先スキーマを確実に確認する
   ```bash
   source .venv/bin/activate
   dbt compile --profiles-dir ~/.dbt --no-use-colors
   cat target/manifest.json | jq '.nodes."model.pivot_dbt.MODEL_NAME" | {database: .database, schema: .schema, name: .name}'
   ```
3. 「テーブル作成先スキーマは xxxx です。dbt run を実行してもよろしいですか？」とユーザーに確認
4. 許可を得た後に `dbt run --select model_name --profiles-dir ~/.dbt --no-use-colors`
