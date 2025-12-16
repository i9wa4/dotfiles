---
title: "BigQuery 補足ドキュメント"
source_url: "https://cloud.google.com/bigquery/docs"
fetched_at: "2025-12-17T00:00:00+09:00"
---

# BigQuery 補足ドキュメント

## 1. データ型

### 1.1. 基本データ型

| 型 | 説明 | 例 |
|---|---|---|
| INT64 | 64ビット整数 | 123 |
| FLOAT64 | 倍精度浮動小数点 | 3.14 |
| NUMERIC | 固定精度数値（38桁、小数9桁） | 123.456789 |
| BIGNUMERIC | 大きな固定精度数値（76桁、小数38桁） | 大規模な金融計算向け |
| BOOL | 真偽値 | TRUE, FALSE |
| STRING | 可変長 UTF-8 文字列 | 'hello' |
| BYTES | 可変長バイナリ | b'\x00\x01' |
| DATE | 日付（時刻なし） | DATE '2024-01-15' |
| TIME | 時刻（日付なし） | TIME '14:30:00' |
| DATETIME | 日時（タイムゾーンなし） | DATETIME '2024-01-15 14:30:00' |
| TIMESTAMP | タイムゾーン付き日時 | TIMESTAMP '2024-01-15 14:30:00 UTC' |
| GEOGRAPHY | 地理空間データ | ST_GEOGPOINT(139.69, 35.68) |
| JSON | JSON データ | JSON '{"key": "value"}' |

### 1.2. 複合型

```sql
-- ARRAY（配列）
DECLARE arr ARRAY<STRING>;
SET arr = ['a', 'b', 'c'];

-- STRUCT（構造体）
DECLARE s STRUCT<name STRING, age INT64>;
SET s = STRUCT('John', 30);

-- 配列とスタの組み合わせ
SELECT
  ARRAY<STRUCT<x INT64, y INT64>>[
    STRUCT(1, 2),
    STRUCT(3, 4)
  ] AS points;
```

## 2. 高度なクエリパターン

### 2.1. PIVOT / UNPIVOT

```sql
-- PIVOT: 行を列に変換
SELECT *
FROM (
  SELECT category, region, sales
  FROM sales_data
)
PIVOT (
  SUM(sales) FOR region IN ('East', 'West', 'North', 'South')
);

-- UNPIVOT: 列を行に変換
SELECT *
FROM wide_table
UNPIVOT (
  value FOR metric IN (metric1, metric2, metric3)
);
```

### 2.2. 再帰 CTE

```sql
-- 階層データの展開
WITH RECURSIVE hierarchy AS (
  -- ベースケース
  SELECT id, parent_id, name, 1 AS level
  FROM org_chart
  WHERE parent_id IS NULL

  UNION ALL

  -- 再帰ケース
  SELECT c.id, c.parent_id, c.name, h.level + 1
  FROM org_chart c
  JOIN hierarchy h ON c.parent_id = h.id
)
SELECT * FROM hierarchy;
```

### 2.3. QUALIFY（ウィンドウ関数のフィルタ）

```sql
-- 各カテゴリの最新レコードを取得
SELECT *
FROM transactions
QUALIFY ROW_NUMBER() OVER (PARTITION BY category ORDER BY created_at DESC) = 1;
```

### 2.4. TABLESAMPLE

```sql
-- テーブルからサンプリング（高速な概算分析用）
SELECT *
FROM `project.dataset.large_table` TABLESAMPLE SYSTEM (10 PERCENT);
```

## 3. DML 操作

### 3.1. INSERT

```sql
-- 単一行挿入
INSERT INTO `project.dataset.table` (col1, col2)
VALUES ('value1', 'value2');

-- 複数行挿入
INSERT INTO `project.dataset.table` (col1, col2)
VALUES
  ('a', 'b'),
  ('c', 'd');

-- SELECT からの挿入
INSERT INTO `project.dataset.target`
SELECT * FROM `project.dataset.source` WHERE condition;
```

### 3.2. UPDATE

```sql
-- 条件付き更新
UPDATE `project.dataset.table`
SET column1 = 'new_value'
WHERE id = 123;

-- 別テーブルを参照した更新
UPDATE `project.dataset.table` t
SET t.status = s.new_status
FROM `project.dataset.status_updates` s
WHERE t.id = s.id;
```

### 3.3. DELETE

```sql
-- 条件付き削除
DELETE FROM `project.dataset.table`
WHERE created_at < DATE_SUB(CURRENT_DATE(), INTERVAL 90 DAY);
```

### 3.4. MERGE

```sql
-- UPSERT（存在すれば更新、なければ挿入）
MERGE INTO `project.dataset.target` AS t
USING `project.dataset.source` AS s
ON t.id = s.id
WHEN MATCHED THEN
  UPDATE SET t.value = s.value, t.updated_at = CURRENT_TIMESTAMP()
WHEN NOT MATCHED THEN
  INSERT (id, value, created_at) VALUES (s.id, s.value, CURRENT_TIMESTAMP());
```

## 4. マテリアライズドビュー

### 4.1. 作成

```sql
-- 自動更新されるマテリアライズドビュー
CREATE MATERIALIZED VIEW `project.dataset.mv_daily_sales`
OPTIONS (
  enable_refresh = true,
  refresh_interval_minutes = 60
)
AS
SELECT
  DATE(created_at) AS date,
  category,
  SUM(amount) AS total_amount,
  COUNT(*) AS count
FROM `project.dataset.transactions`
GROUP BY date, category;
```

### 4.2. 利点

- 自動的にクエリを最適化（クエリリライト）
- 増分更新でコスト削減
- ベーステーブルの変更を自動追跡

## 5. タイムトラベル

```sql
-- 過去のある時点のデータを取得（最大7日間）
SELECT *
FROM `project.dataset.table`
FOR SYSTEM_TIME AS OF TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 HOUR);

-- 特定のタイムスタンプ
SELECT *
FROM `project.dataset.table`
FOR SYSTEM_TIME AS OF '2024-01-15 10:00:00 UTC';
```

## 6. スナップショットとクローン

### 6.1. テーブルスナップショット

```sql
-- スナップショット作成（読み取り専用、過去の状態を保存）
CREATE SNAPSHOT TABLE `project.dataset.snapshot_20240115`
CLONE `project.dataset.source_table`
FOR SYSTEM_TIME AS OF '2024-01-15 00:00:00 UTC';
```

### 6.2. テーブルクローン

```sql
-- クローン作成（書き込み可能、コピーオンライト）
CREATE TABLE `project.dataset.table_clone`
CLONE `project.dataset.source_table`;
```

## 7. スクリプトと変数

### 7.1. 変数宣言と使用

```sql
DECLARE start_date DATE DEFAULT DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY);
DECLARE end_date DATE DEFAULT CURRENT_DATE();

SELECT *
FROM `project.dataset.table`
WHERE date BETWEEN start_date AND end_date;
```

### 7.2. IF / LOOP

```sql
DECLARE i INT64 DEFAULT 0;

WHILE i < 10 DO
  -- 処理
  SET i = i + 1;
END WHILE;

IF condition THEN
  -- 処理
ELSEIF other_condition THEN
  -- 処理
ELSE
  -- 処理
END IF;
```

### 7.3. 例外処理

```sql
BEGIN
  -- メイン処理
  SELECT * FROM `project.dataset.table`;
EXCEPTION WHEN ERROR THEN
  -- エラー処理
  SELECT @@error.message;
END;
```

## 8. ストアドプロシージャ

```sql
-- プロシージャ作成
CREATE OR REPLACE PROCEDURE `project.dataset.update_stats`(
  IN target_date DATE,
  OUT rows_updated INT64
)
BEGIN
  UPDATE `project.dataset.stats`
  SET processed = TRUE
  WHERE date = target_date;

  SET rows_updated = @@row_count;
END;

-- プロシージャ呼び出し
DECLARE updated INT64;
CALL `project.dataset.update_stats`('2024-01-15', updated);
SELECT updated;
```

## 9. ユーザー定義関数（UDF）

### 9.1. SQL UDF

```sql
CREATE OR REPLACE FUNCTION `project.dataset.add_tax`(price FLOAT64, rate FLOAT64)
RETURNS FLOAT64
AS (price * (1 + rate));

-- 使用
SELECT add_tax(1000, 0.1);  -- 1100.0
```

### 9.2. JavaScript UDF

```sql
CREATE OR REPLACE FUNCTION `project.dataset.parse_json_array`(json_str STRING)
RETURNS ARRAY<STRING>
LANGUAGE js
AS """
  return JSON.parse(json_str);
""";
```

## 10. INFORMATION_SCHEMA

### 10.1. テーブルメタデータ

```sql
-- データセット内のテーブル一覧
SELECT table_name, table_type, creation_time
FROM `project.dataset.INFORMATION_SCHEMA.TABLES`;

-- カラム情報
SELECT column_name, data_type, is_nullable
FROM `project.dataset.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'my_table';
```

### 10.2. ジョブ履歴

```sql
-- 過去24時間のジョブ
SELECT
  job_id,
  user_email,
  total_bytes_processed,
  total_slot_ms
FROM `region-us`.INFORMATION_SCHEMA.JOBS_BY_PROJECT
WHERE creation_time > TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 DAY)
ORDER BY total_bytes_processed DESC;
```

### 10.3. パーティション情報

```sql
-- パーティション統計
SELECT
  partition_id,
  total_rows,
  total_logical_bytes
FROM `project.dataset.INFORMATION_SCHEMA.PARTITIONS`
WHERE table_name = 'partitioned_table'
ORDER BY partition_id DESC;
```

## 11. トラブルシューティング

### 11.1. よくあるエラー

| エラー | 原因 | 対処法 |
|---|---|---|
| Resources exceeded | メモリ不足 | クエリを分割、APPROX_ 関数使用 |
| Query timeout | 実行時間超過 | クエリ最適化、パーティション活用 |
| Quota exceeded | クォータ制限 | バッチ処理、クォータ増加申請 |
| Access denied | 権限不足 | IAM ロール確認 |

### 11.2. クエリプラン確認

```sql
-- 実行プランを表示
-- Cloud Console で「実行の詳細」タブを確認
-- または EXPLAIN ステートメント（ドライラン）を使用
```

## 12. ベストプラクティスまとめ

1. パーティションとクラスタリングを適切に設計
2. SELECT * を避け、必要なカラムのみ取得
3. WHERE 句でパーティションフィルタを使用
4. 大規模な JOIN は事前にフィルタリング
5. マテリアライズドビューで繰り返しクエリを最適化
6. ドライランでコストを事前確認
7. 適切な IAM 権限でアクセス制御
8. INFORMATION_SCHEMA でモニタリング
