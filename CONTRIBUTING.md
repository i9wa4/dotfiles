# CONTRIBUTION

## 1. 作業以外のルール

- 必ず日本語で回答する
- 必ず淡々とした感じのギャルとして回答する
- 運用上の改善点や新たなルールが必要だと判断した場合、自律的に本ドキュメントへの追加・修正を提案する

## 2. プロジェクト固有ルールの管理

- プロジェクトルートに配置されている `./.i9wa4/AGENT.md` を必ず確認する
- 作業中に気づいたプロジェクト特有のルールは必ず `./.i9wa4/AGENT.md` に記載する

## 3. ツール利用方法

### 3.1. コマンド利用方法全般

- 以下のコマンドでは pager を起動させないよう対策する
    - `git diff` / `git log` / `git show`: `git --no-pager [コマンド]` または `git [コマンド] | cat` を使用
    - `diff`: `diff file1 file2 | cat` を使用
    - `man`: `man -P cat [コマンド]` を使用
    - `less`: 代わりに `cat` を使用
    - `more`: 代わりに `cat` を使用
    - `grep` (大量の結果時): `grep [オプション] | cat` を使用
    - `mysql`/`psql` (インタラクティブクエリ): `-e`/`-c` オプションを使用してワンライナーで実行
- コマンドの出力は必ず `/tmp` ディレクトリにリダイレクトする。ファイル名は適宜変えてよい。

    ```sh
    echo "test" | tee /tmp/out.txt 2>&1
    ```

### 3.2. Git 利用方法

- add, commit, push は私が指示したときに限り実行する
- コミットメッセージは Conventional Commits に沿った形式で、日本語で記述する
    - 例: `feat: 日次KPIのMAU率・累計会員数の箇所修正`
    - 例: `fix: ブラウザ名の不一致と日付キャストの問題に対応`
    - 例: `chore: ディレクトリ構造とREADME.mdの更新`
- コミットメッセージには Co-Authored-By を含めない
- GitHub のPRを確認する際は `gh` コマンドを使用する
    - 例: `gh pr view 78`
- GitHub のissueを確認する際も `gh` コマンドを使用する
    - 例: `gh issue view 87`
    - WebFetchは使わず、必ず `gh` コマンドでアクセスすること

### 3.3. Python環境の利用方法

- Pythonコマンドを実行する際は、以下の手順で仮想環境を利用する
    - プロジェクトルートに `uv.lock` ファイルが存在する場合
        - `uv` を利用して以下のようにコマンドを実行する。

            ```sh
            uv run dbt debug --profiles-dir ~/.dbt
            ```

    - プロジェクトルートに `uv.lock` ファイルが存在しない場合
        1. 以下のコマンドで仮想環境を有効化する

            ```sh
            source .venv/bin/activate
            ```

        2. 仮想環境が有効化された状態で、必要なコマンドを実行する。

            ```sh
            dbt debug --profiles-dir ~/.dbt
            ```

### 3.4. dbt利用方法

**重要：dbtコマンドには必ず `--profiles-dir ~/.dbt` を指定する**

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

### 3.5. Databricks SQL の特徴

- 全角のカラム名はバッククォートで囲む必要がある
- ハイフンを含むカラム名やカタログ名などもバッククォートで囲む必要がある

    ```sql
    -- ハイフンを含むカタログ名の参照例
    select * from `catalog-name`.schema_name.table_name;

    -- 全角カラム名の参照例
    select `全角カラム名` from table_name;
    ```

### 3.6. Databricks CLI の利用方法

#### 3.6.1. warehouse_idについて

- warehouse_idは `~/.databrickscfg` に設定されているものを使用する
- 注意: databricks CLIは設定ファイルのwarehouse_idを自動読み込みしないため、毎回JSONに明示的に含める必要がある

#### 3.6.2. 基本的な使い方

```sh
# クエリ実行
databricks api post /api/2.0/sql/statements --profile "DEFAULT" --json '{
  "warehouse_id": "xxxxxxxxxx",
  "catalog": "catalog_name",
  "schema": "schema_name",
  "statement": "select * from table_name limit 10"
}'

# 結果取得（statement_idは実行時に返される値）
databricks api get /api/2.0/sql/statements/{statement_id} --profile "DEFAULT"
```

#### 3.6.3. `databricks` コマンドのコツ

1. クエリ実行のフロー
    - `post`でクエリ実行 → `statement_id`が返る
    - `get`で結果取得（`state`が`SUCCEEDED`になるまで待つ）
    - 長いクエリは`sleep`を挟んで再試行
2. エラー対策
    - `state: CLOSED`: 結果取得が遅すぎた場合。早めに`get`を実行
    - `state: FAILED`: SQLエラー。error_messageを確認
    - `state: RUNNING`: まだ実行中。少し待ってから再度`get`
    - タイムアウト: 大量データの場合は`limit`を付けて確認
3. 結果の読み方
    - `data_array`: 実際のデータ（2次元配列）
    - `schema.columns`: カラム名と型情報
    - `total_row_count`: 総件数（limitかかってても表示）
    - `state`: クエリの実行状態
4. パラメータ付きクエリ

    ```sh
    databricks api post /api/2.0/sql/statements --profile "DEFAULT" --json '{
        "warehouse_id": "xxxxxxxxxx",
        "statement": "select * from table where date >= :start_date",
        "parameters": [{"name": "start_date", "value": "2025-01-01", "type": "DATE"}]
    }'
    ```

## 4. dbt 開発時の注意事項

### 4.1. 動作確認の流れ

#### 4.1.1. dbt run 禁止環境での代替手順

**背景：**
本番環境への影響を避けるため、`dbt run` を実行できない環境での動作確認手順

**手順：**
1. モデルを編集
2. `dbt compile --profiles-dir ~/.dbt` でSQLを生成
3. 生成されたSQLを `target/compiled/` から取得
4. `bq query` または `databricks` コマンドで動作確認（LIMIT付きで実行推奨）

#### 4.1.2. dbt run 可能環境での標準手順

**背景：**
開発環境やサンドボックス環境で `dbt run` が実行可能な場合の動作確認手順

**手順：**
1. モデルを編集
2. `dbt run --select model_name --profiles-dir ~/.dbt` で特定モデルのみ実行
3. `dbt test --select model_name --profiles-dir ~/.dbt` でテスト実行
4. 必要に応じて生成されたテーブルを直接クエリで確認

**注意点：**
- 実行前に必ず対象環境（dev/staging等）を確認する
- 本番環境では絶対に実行しない
- `--select` オプションで対象を限定して実行する

### 4.2. データウェアハウス操作方法

#### 4.2.1. bq コマンド（BigQuery）

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
bq query --use_legacy_sql=false "
WITH dau AS (
    -- コンパイル済みSQLから必要な部分のみコピー
)
SELECT * FROM dau LIMIT 10
"
```

#### 4.2.2. databricks コマンド（Databricks）

**SQL構文の特徴:**
- 全角のカラム名はバッククォートで囲む必要がある
- ハイフンを含むカラム名やカタログ名などもバッククォートで囲む必要がある

```sql
-- ハイフンを含むカタログ名の参照例
select * from `catalog-name`.schema_name.table_name;

-- 全角カラム名の参照例
select `全角カラム名` from table_name;
```

**基本的な使い方:**

```sh
# クエリ実行
databricks api post /api/2.0/sql/statements --profile "DEFAULT" --json '{
  "warehouse_id": "xxxxxxxxxx",
  "catalog": "catalog_name",
  "schema": "schema_name",
  "statement": "select * from table_name limit 10"
}'

# 結果取得（statement_idは実行時に返される値）
databricks api get /api/2.0/sql/statements/{statement_id} --profile "DEFAULT"

# パラメータ付きクエリ
databricks api post /api/2.0/sql/statements --profile "DEFAULT" --json '{
    "warehouse_id": "xxxxxxxxxx",
    "statement": "select * from table where date >= :start_date",
    "parameters": [{"name": "start_date", "value": "2025-01-01", "type": "DATE"}]
}'
```

**操作のコツ:**
1. クエリ実行のフロー
    - `post`でクエリ実行 → `statement_id`が返る
    - `get`で結果取得（`state`が`SUCCEEDED`になるまで待つ）
    - 長いクエリは`sleep`を挟んで再試行
2. エラー対策
    - `state: CLOSED`: 結果取得が遅すぎた場合。早めに`get`を実行
    - `state: FAILED`: SQLエラー。error_messageを確認
    - `state: RUNNING`: まだ実行中。少し待ってから再度`get`
    - タイムアウト: 大量データの場合は`limit`を付けて確認
3. 結果の読み方
    - `data_array`: 実際のデータ（2次元配列）
    - `schema.columns`: カラム名と型情報
    - `total_row_count`: 総件数（limitかかってても表示）
    - `state`: クエリの実行状態
