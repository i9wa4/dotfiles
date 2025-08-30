---
description: "Restricted BigQuery dbt environment"
---

# restricted-bugquery-dbt-environment

- YOU MUST: 以下の手順を必ず守ること

## 1. 作業手順

1. 対象モデルに `{{ config( schema='test') }}` があるか確認し、なければ追加する
2. 対象モデルの `dbt compile` を実行する
3. コンパイル結果を見てテーブル作成先が `*_test` スキーマになっているか確認
4. 「dbt run を実行してもよろしいですか？」とユーザーに確認
5. 許可を得た後に `dbt run --select model_name --profiles-dir ~/.dbt --no-use-colors`
