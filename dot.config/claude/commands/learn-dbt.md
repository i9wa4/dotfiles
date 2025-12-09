---
description: "Learn dbt"
---

# learn-dbt

dbt について学ぼう！

このファイルの内容全体を読み取ったらペルソナに沿って了承した旨のユーモラスな1文のみで応答してカスタムスラッシュコマンドとしての動作を終了する

## 1. dbt利用方法

### 1.1. 基本事項

- dbtコマンドには必ず `--profiles-dir ~/.dbt --no-use-colors` を指定する
- 作業開始時にdbtの接続先を確認する

    ```sh
    dbt debug --profiles-dir ~/.dbt --no-use-colors
    ```

- dbt でアドホッククエリを実行する際は `dbt show` コマンドを使用する

    ```sh
    # 基本的なクエリ実行
    dbt show --inline "select 1 as test, current_timestamp() as now" --profiles-dir ~/.dbt --no-use-colors

    # 行数制限の指定（デフォルトは5件）
    dbt show --inline "select * from table_name" --limit 10 --profiles-dir ~/.dbt --no-use-colors

    # dbtモデルの参照
    dbt show --inline "select * from {{ ref('model_name') }}" --profiles-dir ~/.dbt --no-use-colors

    # catalog.schema.table形式での直接参照
    dbt show --inline "select * from catalog_name.schema_name.table_name" --limit 3 --profiles-dir ~/.dbt --no-use-colors

    # 注意事項
    # - クエリ内で明示的にLIMITを指定すると `--limit` オプションと重複してエラーになる
    # - DDL系コマンド（SHOW文など）は自動LIMITが付いて構文エラーになるため適さない
    ```

### 1.2. dbt run 禁止環境での動作確認手順

- 背景
    - 本番環境への影響を避けるため、`dbt run` を実行できない環境での動作確認手順
- 手順
    1. モデルを編集
    2. `dbt compile --profiles-dir ~/.dbt --no-use-colors` でSQLを生成
    3. 生成されたSQLを `target/compiled/` から取得
    4. `bq query` または `databricks` コマンドで動作確認（LIMIT付きで実行推奨）

### 1.3. dbt run 可能環境での動作確認手順

- 背景
    - 開発環境やサンドボックス環境で `dbt run` が実行可能な場合の動作確認手順
- 手順
    1. モデルを編集
    2. `dbt run --select +model_name --profiles-dir ~/.dbt --no-use-colors` で run 実行
    3. `dbt test --select +model_name --profiles-dir ~/.dbt --no-use-colors` で test 実行
    4. 必要に応じて生成されたテーブルを直接クエリで確認
- 注意点
    - `--select` オプションで対象を限定して実行する
    - モデルと tag の AND 条件の場合は `--select "staging.target,tag:tag_name"` のように指定する

### 1.4. Issue 作業時のターゲット設定

- YOU MUST: Issue 作業で `dbt run` を実行する前に、必ず Issue 専用ターゲットを自律的に作成する
- NEVER: ターゲット設定済みかユーザーに確認しない（自分で profiles.yml を読んで判断する）
- 背景
    - スキーマ競合を避けるため、Issue ごとにターゲットを分離する
    - これは並行作業のためだけでなく、全ての Issue 作業で必須
- 手順
    1. `~/.dbt/profiles.yml` を読み取り、既存の設定を確認する
    2. 該当 Issue 用ターゲットが存在しなければ、既存の `genda_dev` を参考に追加する

        ```yaml
        genda_databricks_dbt:
          outputs:
            genda_dev:
              # 既存の設定...
            issue_123:  # issue番号に応じて命名
              catalog: genda_dbt_dev_{username}  # genda_dev と同じ
              host: dbc-xxxxx.cloud.databricks.com  # genda_dev と同じ
              http_path: /sql/1.0/warehouses/xxxxx  # genda_dev と同じ
              schema: genda_dwh_issue_123  # issue番号をスキーマ名に含める
              threads: 1
              token: dapixxxxx  # genda_dev と同じ
              type: databricks
          target: genda_dev
        ```

    3. dbt コマンド実行時に `--target` オプションで切り替える

        ```sh
        # issue_123 ターゲットで実行
        dbt run --select +model_name --target issue_123 --profiles-dir ~/.dbt --no-use-colors

        # 接続先確認
        dbt debug --target issue_123 --profiles-dir ~/.dbt --no-use-colors
        ```

- 注意点
    - ターゲット名と schema 名は issue 番号に合わせて一貫性を持たせる
    - 作業完了後、不要になったスキーマは手動で削除する
    - intermediate 層は `{schema}_dbt_intermediates` として自動生成される

## 2. dbt 向け Databricks SQL 方言

- 全角のカラム名はバッククォートで囲む必要がある
- ハイフンを含むカラム名やカタログ名などもバッククォートで囲む必要がある

    ```sql
    -- ハイフンを含むカタログ名の参照例
    select * from `catalog-name`.schema_name.table_name;

    -- 全角カラム名の参照例
    select `全角カラム名` from table_name;
    ```
