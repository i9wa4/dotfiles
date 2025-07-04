---
description: "learn BigQuery"
---

# learn-bigquery

## 1. bq コマンド (BigQuery)

```sh
# データセット一覧
bq ls --project_id=project-name

# テーブル一覧
bq ls --format=pretty project-name:dataset_name

# テーブル詳細
bq show --format=prettyjson project-name:dataset_name.table_name

# テーブルスキーマ
bq show --schema --format=prettyjson project-name:dataset_name.table_name

# クエリ実行（必ずLIMIT付き）
bq query --use_legacy_sql=false "SELECT * FROM \`project-name.dataset_name.table_name\` LIMIT 10"

# コンパイル済みSQLの実行
COMPILED_SQL=$(cat target/compiled/target_model.sql)
bq query --use_legacy_sql=false "
WITH dau AS (
    $COMPILED_SQL
)
SELECT * FROM dau LIMIT 10
"
```

