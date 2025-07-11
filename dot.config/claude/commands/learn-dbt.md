---
description: "Learn dbt"
---

# learn-dbt

dbt について学ぼう！

## 1. dbt利用方法

### 1.1. 基本事項

- dbtコマンドには必ず `--profiles-dir ~/.dbt` を指定する
- 作業開始時にdbtの接続先を確認する

    ```sh
    dbt debug --profiles-dir ~/.dbt
    ```

- dbt でアドホッククエリを実行する際は `dbt show` コマンドを使用する

    ```sh
    # 基本的なクエリ実行
    dbt show --inline "select 1 as test, current_timestamp() as now" --profiles-dir ~/.dbt

    # 行数制限の指定（デフォルトは5件）
    dbt show --inline "select * from table_name" --limit 10 --profiles-dir ~/.dbt

    # dbtモデルの参照
    dbt show --inline "select * from {{ ref('model_name') }}" --profiles-dir ~/.dbt

    # catalog.schema.table形式での直接参照
    dbt show --inline "select * from catalog_name.schema_name.table_name" --limit 3 --profiles-dir ~/.dbt

    # 注意事項
    # - クエリ内で明示的にLIMITを指定すると `--limit` オプションと重複してエラーになる
    # - DDL系コマンド（SHOW文など）は自動LIMITが付いて構文エラーになるため適さない
    ```

### 1.2. dbt run 禁止環境での動作確認手順

- 背景
    - 本番環境への影響を避けるため、`dbt run` を実行できない環境での動作確認手順
- 手順
    1. モデルを編集
    2. `dbt compile --profiles-dir ~/.dbt` でSQLを生成
    3. 生成されたSQLを `target/compiled/` から取得
    4. `bq query` または `databricks` コマンドで動作確認（LIMIT付きで実行推奨）

### 1.3. dbt run 可能環境での動作確認手順

- 背景
    - 開発環境やサンドボックス環境で `dbt run` が実行可能な場合の動作確認手順
- 手順
    1. モデルを編集
    2. `dbt run --select +model_name --profiles-dir ~/.dbt` で run 実行
    3. `dbt test --select +model_name --profiles-dir ~/.dbt` で test 実行
    4. 必要に応じて生成されたテーブルを直接クエリで確認
- 注意点
    - `--select` オプションで対象を限定して実行する

## 3. dbt 向け Databricks SQL 方言

- 全角のカラム名はバッククォートで囲む必要がある
- ハイフンを含むカラム名やカタログ名などもバッククォートで囲む必要がある

    ```sql
    -- ハイフンを含むカタログ名の参照例
    select * from `catalog-name`.schema_name.table_name;

    -- 全角カラム名の参照例
    select `全角カラム名` from table_name;
    ```
