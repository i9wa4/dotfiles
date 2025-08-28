---
description: "Restricted BigQuery dbt environment"
---

# restricted-bugquery-dbt-environment

- YOU MUST: 今回の開発環境では動作確認時にスキーマ作成先を以下のように指定する必要がある
- YOU MUST: dbt run 実行前に毎回必ず schema 設定がされていることを確認する

## dbt run 対象モデルの config 編集内容

```sql
{{ config(
    schema='test'
) }}
```
