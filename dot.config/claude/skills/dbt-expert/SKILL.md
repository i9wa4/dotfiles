---
name: dbt-expert
description: dbt エキスパートエンジニアスキル - dbt 開発のベストプラクティス、コマンド実行、環境設定に関する包括的なガイドを提供
---

# dbt Expert Engineer Skill

このスキルは dbt 開発に関する包括的なガイドを提供する。

## 1. dbt コマンドの基本

### 1.1. 必須オプション

dbt コマンドには必ず以下のオプションを指定する

```sh
--profiles-dir ~/.dbt --no-use-colors
```

### 1.2. 接続確認

作業開始時に必ず接続先を確認する

```sh
dbt debug --profiles-dir ~/.dbt --no-use-colors
```

### 1.3. アドホッククエリの実行

dbt でアドホッククエリを実行する際は `dbt show` コマンドを使用する

```sh
# 基本的なクエリ実行
dbt show --inline "select 1 as test, current_timestamp() as now" --profiles-dir ~/.dbt --no-use-colors

# 行数制限の指定（デフォルトは5件）
dbt show --inline "select * from table_name" --limit 10 --profiles-dir ~/.dbt --no-use-colors

# dbtモデルの参照
dbt show --inline "select * from {{ ref('model_name') }}" --profiles-dir ~/.dbt --no-use-colors

# catalog.schema.table形式での直接参照
dbt show --inline "select * from catalog_name.schema_name.table_name" --limit 3 --profiles-dir ~/.dbt --no-use-colors
```

注意事項:

- クエリ内で明示的に LIMIT を指定すると `--limit` オプションと重複してエラーになる
- DDL系コマンド（SHOW文など）は自動LIMITが付いて構文エラーになるため適さない

## 2. 動作確認手順

### 2.1. dbt run 禁止環境での動作確認

本番環境への影響を避けるため、`dbt run` を実行できない環境での動作確認手順

1. モデルを編集
2. `dbt compile --profiles-dir ~/.dbt --no-use-colors` でSQLを生成
3. 生成されたSQLを `target/compiled/` から取得
4. `bq query` または `databricks` コマンドで動作確認（LIMIT付きで実行推奨）

### 2.2. dbt run 可能環境での動作確認

開発環境やサンドボックス環境で `dbt run` が実行可能な場合の動作確認手順

1. モデルを編集
2. `dbt run --select +model_name --profiles-dir ~/.dbt --no-use-colors` で run 実行
3. `dbt test --select +model_name --profiles-dir ~/.dbt --no-use-colors` で test 実行
4. 必要に応じて生成されたテーブルを直接クエリで確認

注意点:

- `--select` オプションで対象を限定して実行する
- モデルと tag の AND 条件の場合は `--select "staging.target,tag:tag_name"` のように指定する

## 3. Issue 作業時のターゲット設定

Issue 作業で `dbt run` を実行する前に、必ず Issue 専用ターゲットを設定する

### 3.1. 設定手順

1. `~/.dbt/profiles.yml` を読み取り、既存の設定を確認する
2. 該当 Issue 用ターゲットが存在しなければ、既存の `dev` ターゲットを参考に追加する

```yaml
my_databricks_dbt:
  outputs:
    dev:
      # 既存の設定...
    issue_123:  # issue番号に応じて命名
      catalog: dbt_dev_{username}  # dev と同じ
      host: dbc-xxxxx.cloud.databricks.com  # dev と同じ
      http_path: /sql/1.0/warehouses/xxxxx  # dev と同じ
      schema: dwh_issue_123  # issue番号をスキーマ名に含める
      threads: 1
      token: dapixxxxx  # dev と同じ
      type: databricks
  target: dev
```

3. dbt コマンド実行時に `--target` オプションで切り替える

```sh
# issue_123 ターゲットで実行
dbt run --select +model_name --target issue_123 --profiles-dir ~/.dbt --no-use-colors

# 接続先確認
dbt debug --target issue_123 --profiles-dir ~/.dbt --no-use-colors
```

### 3.2. 注意点

- ターゲット名と schema 名は issue 番号に合わせて一貫性を持たせる
- 作業完了後、不要になったスキーマは手動で削除する
- intermediate 層は `{schema}_dbt_intermediates` として自動生成される

## 4. Databricks SQL 方言

- 全角のカラム名はバッククォートで囲む必要がある
- ハイフンを含むカラム名やカタログ名などもバッククォートで囲む必要がある

```sql
-- ハイフンを含むカタログ名の参照例
select * from `catalog-name`.schema_name.table_name;

-- 全角カラム名の参照例
select `全角カラム名` from table_name;
```

## 5. ベストプラクティスドキュメント

`docs/` ディレクトリに以下のベストプラクティスドキュメントが含まれている

### 5.1. プロジェクト構造

- `1-guide-overview.md` - 構造ガイド概要
- `2-staging.md` - ステージング層
- `3-intermediate.md` - 中間層
- `4-marts.md` - マート層
- `5-semantic-layer.md` - セマンティックレイヤー

### 5.2. スタイルガイド

- `0-how-we-style-our-dbt-projects.md` - プロジェクトスタイル概要
- `1-how-we-style-our-dbt-models.md` - モデルスタイル
- `2-how-we-style-our-sql.md` - SQL スタイル
- `3-how-we-style-our-python.md` - Python スタイル
- `4-how-we-style-our-jinja.md` - Jinja スタイル
- `5-how-we-style-our-yaml.md` - YAML スタイル

### 5.3. マテリアライゼーション

- `1-guide-overview.md` - マテリアライゼーション概要
- `2-available-materializations.md` - 利用可能なマテリアライゼーション
- `3-configuring-materializations.md` - 設定方法
- `4-incremental-models.md` - インクリメンタルモデル
- `5-best-practices.md` - ベストプラクティス

### 5.4. dbt Mesh

- `mesh-1-intro.md` - dbt Mesh 入門
- `mesh-2-who-is-dbt-mesh-for.md` - 対象ユーザー
- `mesh-3-structures.md` - 構造
- `mesh-4-implementation.md` - 実装
- `mesh-5-faqs.md` - FAQ

## 6. ドキュメント検索

```bash
python scripts/search_docs.py "<query>"
```

オプション:

- `--json` - JSON形式で出力
- `--max-results N` - 結果数を制限（デフォルト: 10）

## 7. 回答時のフォーマット

```
[ドキュメントに基づく回答]

**Source:** [source_url]
**Fetched:** [fetched_at]
```
