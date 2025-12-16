---
name: bigquery-expert
description: BigQuery エキスパートエンジニアスキル - GoogleSQL クエリ、データ管理、パフォーマンス最適化、コスト管理に関する包括的なガイドを提供
---

# BigQuery Expert Engineer Skill

このスキルは BigQuery 開発に関する包括的なガイドを提供する。

## 1. bq コマンドラインツールの基本

### 1.1. クエリ実行

```sh
# 標準 SQL でクエリ実行
bq query --use_legacy_sql=false 'SELECT * FROM `project.dataset.table` LIMIT 10'

# 結果を CSV 形式で出力
bq query --use_legacy_sql=false --format=csv 'SELECT * FROM `project.dataset.table`'

# ドライラン（コスト見積もり）
bq query --use_legacy_sql=false --dry_run 'SELECT * FROM `project.dataset.table`'

# 結果をテーブルに保存
bq query --use_legacy_sql=false --destination_table=project:dataset.result_table 'SELECT * FROM `project.dataset.table`'
```

### 1.2. テーブル操作

```sh
# テーブル一覧
bq ls project:dataset

# テーブルスキーマ確認
bq show --schema --format=prettyjson project:dataset.table

# テーブル作成（スキーマファイルから）
bq mk --table project:dataset.table schema.json

# パーティションテーブル作成
bq mk --table --time_partitioning_field=created_at project:dataset.table schema.json

# クラスタリングテーブル作成
bq mk --table --clustering_fields=user_id,category project:dataset.table schema.json

# テーブル削除
bq rm -t project:dataset.table
```

### 1.3. データのロード/エクスポート

```sh
# CSV からロード
bq load --source_format=CSV project:dataset.table gs://bucket/data.csv schema.json

# JSON からロード
bq load --source_format=NEWLINE_DELIMITED_JSON project:dataset.table gs://bucket/data.json

# Parquet からロード（スキーマ自動検出）
bq load --source_format=PARQUET --autodetect project:dataset.table gs://bucket/data.parquet

# Cloud Storage へエクスポート
bq extract --destination_format=CSV project:dataset.table gs://bucket/export/*.csv
```

## 2. GoogleSQL の基本構文

### 2.1. SELECT 文

```sql
-- 基本的な SELECT
SELECT
  column1,
  column2,
  COUNT(*) AS count
FROM
  `project.dataset.table`
WHERE
  date >= '2024-01-01'
GROUP BY
  column1, column2
HAVING
  COUNT(*) > 10
ORDER BY
  count DESC
LIMIT 100
```

### 2.2. よく使う関数

```sql
-- 文字列関数
CONCAT(str1, str2)
LOWER(str), UPPER(str)
TRIM(str), LTRIM(str), RTRIM(str)
SUBSTR(str, start, length)
REGEXP_CONTAINS(str, r'pattern')
REGEXP_EXTRACT(str, r'pattern')
SPLIT(str, delimiter)

-- 日付/時刻関数
CURRENT_DATE(), CURRENT_TIMESTAMP()
DATE(timestamp), TIMESTAMP(date)
DATE_ADD(date, INTERVAL 1 DAY)
DATE_DIFF(date1, date2, DAY)
FORMAT_DATE('%Y-%m-%d', date)
PARSE_DATE('%Y%m%d', str)
EXTRACT(YEAR FROM date)

-- 集計関数
COUNT(*), COUNT(DISTINCT column)
SUM(column), AVG(column)
MIN(column), MAX(column)
ARRAY_AGG(column)
STRING_AGG(column, ',')

-- ウィンドウ関数
ROW_NUMBER() OVER (PARTITION BY col ORDER BY col2)
RANK() OVER (ORDER BY col DESC)
LAG(col, 1) OVER (ORDER BY date)
LEAD(col, 1) OVER (ORDER BY date)
SUM(col) OVER (PARTITION BY category)
```

### 2.3. JOIN 構文

```sql
-- INNER JOIN
SELECT a.*, b.column
FROM `project.dataset.table_a` AS a
INNER JOIN `project.dataset.table_b` AS b
  ON a.id = b.id

-- LEFT JOIN
SELECT a.*, b.column
FROM `project.dataset.table_a` AS a
LEFT JOIN `project.dataset.table_b` AS b
  ON a.id = b.id

-- CROSS JOIN（配列展開でよく使用）
SELECT *
FROM `project.dataset.table`,
UNNEST(array_column) AS element
```

### 2.4. CTE（共通テーブル式）

```sql
WITH
  base_data AS (
    SELECT *
    FROM `project.dataset.table`
    WHERE date >= '2024-01-01'
  ),
  aggregated AS (
    SELECT
      category,
      COUNT(*) AS count
    FROM base_data
    GROUP BY category
  )
SELECT *
FROM aggregated
ORDER BY count DESC
```

## 3. テーブル設計

### 3.1. パーティショニング

日付でデータを分割し、クエリのスキャン量を削減

```sql
-- 日付パーティションテーブル作成
CREATE TABLE `project.dataset.partitioned_table`
PARTITION BY DATE(created_at)
AS SELECT * FROM `project.dataset.source_table`;

-- 整数パーティション
CREATE TABLE `project.dataset.int_partitioned`
PARTITION BY RANGE_BUCKET(user_id, GENERATE_ARRAY(0, 1000000, 10000))
AS SELECT * FROM source;

-- パーティションフィルタを必須にする
CREATE TABLE `project.dataset.table`
PARTITION BY DATE(created_at)
OPTIONS (
  require_partition_filter = TRUE
);
```

### 3.2. クラスタリング

指定したカラムでデータをソート・グループ化

```sql
-- クラスタリングテーブル
CREATE TABLE `project.dataset.clustered_table`
PARTITION BY DATE(created_at)
CLUSTER BY user_id, category
AS SELECT * FROM source;
```

### 3.3. ベストプラクティス

- パーティションとクラスタリングを組み合わせる
- クエリでよくフィルタするカラムを選択
- クラスタリングカラムは最大4つまで
- カーディナリティが高いカラムを優先

## 4. パフォーマンス最適化

### 4.1. クエリ最適化

```sql
-- SELECT * を避ける
-- Bad
SELECT * FROM table;
-- Good
SELECT column1, column2 FROM table;

-- パーティションプルーニングを活用
-- Bad（パーティションカラムに関数適用）
WHERE DATE(created_at) = '2024-01-01'
-- Good
WHERE created_at >= '2024-01-01' AND created_at < '2024-01-02'

-- APPROX_ 関数で概算（高速）
SELECT APPROX_COUNT_DISTINCT(user_id) FROM table;
```

### 4.2. JOIN 最適化

```sql
-- 小さいテーブルを右側に（ブロードキャスト JOIN）
SELECT *
FROM large_table
JOIN small_table ON large_table.id = small_table.id;

-- 必要なカラムのみ JOIN
WITH filtered AS (
  SELECT id, needed_column FROM large_table WHERE condition
)
SELECT * FROM filtered JOIN other_table ON ...
```

### 4.3. スロット使用量の確認

```sql
-- ジョブ統計の確認
SELECT
  job_id,
  total_bytes_processed,
  total_slot_ms,
  TIMESTAMP_DIFF(end_time, start_time, SECOND) AS duration_sec
FROM `region-us`.INFORMATION_SCHEMA.JOBS
WHERE creation_time > TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 DAY)
ORDER BY total_slot_ms DESC
LIMIT 10;
```

## 5. コスト管理

### 5.1. 料金体系

- オンデマンド: スキャンしたデータ量に基づく（$5/TB）
- 定額（Editions）: 予約したスロットに基づく
- ストレージ: アクティブ $0.02/GB、長期保存 $0.01/GB

### 5.2. コスト削減のベストプラクティス

1. SELECT * を避ける
2. パーティションフィルタを必ず使用
3. クエリ前にドライランでコスト確認
4. マテリアライズドビューで繰り返しクエリを最適化
5. BI Engine でダッシュボードクエリを高速化

### 5.3. カスタムクォータ設定

```sql
-- プロジェクト単位でクエリバイト数制限
-- Cloud Console または gcloud で設定
```

## 6. データガバナンス

### 6.1. IAM ロール

- `roles/bigquery.admin`: 全権限
- `roles/bigquery.dataEditor`: データの読み書き
- `roles/bigquery.dataViewer`: データの読み取りのみ
- `roles/bigquery.jobUser`: ジョブの実行
- `roles/bigquery.user`: データセット一覧、ジョブ実行

### 6.2. 列レベルセキュリティ

```sql
-- ポリシータグの適用
ALTER TABLE `project.dataset.table`
ALTER COLUMN sensitive_column
SET OPTIONS (policy_tags = ['projects/project/locations/us/taxonomies/123/policyTags/456']);
```

### 6.3. 行レベルセキュリティ

```sql
-- 行アクセスポリシー作成
CREATE ROW ACCESS POLICY region_filter
ON `project.dataset.table`
GRANT TO ('user:analyst@example.com')
FILTER USING (region = 'APAC');
```

## 7. BigQuery ML

### 7.1. モデル作成

```sql
-- 線形回帰モデル
CREATE OR REPLACE MODEL `project.dataset.model`
OPTIONS (
  model_type = 'LINEAR_REG',
  input_label_cols = ['target']
) AS
SELECT feature1, feature2, target
FROM `project.dataset.training_data`;

-- ロジスティック回帰モデル
CREATE OR REPLACE MODEL `project.dataset.classifier`
OPTIONS (
  model_type = 'LOGISTIC_REG',
  input_label_cols = ['label']
) AS
SELECT * FROM training_data;
```

### 7.2. モデル評価と予測

```sql
-- モデル評価
SELECT * FROM ML.EVALUATE(MODEL `project.dataset.model`);

-- 予測
SELECT *
FROM ML.PREDICT(
  MODEL `project.dataset.model`,
  (SELECT * FROM `project.dataset.new_data`)
);
```

## 8. 外部データソース

### 8.1. 外部テーブル

```sql
-- Cloud Storage の CSV を外部テーブルとして参照
CREATE EXTERNAL TABLE `project.dataset.external_table`
OPTIONS (
  format = 'CSV',
  uris = ['gs://bucket/path/*.csv'],
  skip_leading_rows = 1
);

-- Parquet 外部テーブル
CREATE EXTERNAL TABLE `project.dataset.parquet_table`
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://bucket/path/*.parquet']
);
```

### 8.2. Federated Query

```sql
-- Cloud SQL への接続
SELECT * FROM EXTERNAL_QUERY(
  'projects/project/locations/us/connections/connection_id',
  'SELECT * FROM mysql_table'
);
```

## 9. スケジュールクエリ

### 9.1. 設定例

```sql
-- Cloud Console または bq コマンドで設定
-- 毎日午前2時に実行
bq query --use_legacy_sql=false \
  --schedule='every 24 hours' \
  --display_name='Daily aggregation' \
  --destination_table='project:dataset.daily_summary' \
  --replace \
  'SELECT DATE(created_at) as date, COUNT(*) as count FROM source GROUP BY 1'
```

## 10. 詳細ドキュメント

`docs/` ディレクトリに補足ドキュメントが含まれている。

## 11. 参考リンク

- 公式ドキュメント: https://cloud.google.com/bigquery/docs
- GoogleSQL リファレンス: https://cloud.google.com/bigquery/docs/reference/standard-sql/query-syntax
- 関数リファレンス: https://cloud.google.com/bigquery/docs/reference/standard-sql/functions-all
- bq コマンドリファレンス: https://cloud.google.com/bigquery/docs/bq-command-line-tool
- BigQuery ML: https://cloud.google.com/bigquery/docs/bqml-introduction
- 料金: https://cloud.google.com/bigquery/pricing
