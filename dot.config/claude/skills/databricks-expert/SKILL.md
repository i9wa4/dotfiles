---
name: databricks-expert
description: Databricks エキスパートエンジニアスキル - データエンジニアリング、機械学習基盤、権限設計に関する包括的なガイドを提供
---

# Databricks Expert Engineer Skill

このスキルは Databricks 開発に関する包括的なガイドを提供する。

## 1. Databricks CLI の利用方法

### 1.1. warehouse_id について

- warehouse_id は Serverless SQL Warehouse を探して1つ選択する
- 注意: databricks CLI は設定ファイルの warehouse_id を自動読み込みしないため、毎回 JSON に明示的に含める必要がある

### 1.2. 基本的な使い方

```sh
# クエリ実行
databricks api post /api/2.0/sql/statements --profile "DEFAULT" --json '{
  "warehouse_id": "xxxxxxxxxx",
  "catalog": "catalog_name",
  "schema": "schema_name",
  "statement": "select * from table_name limit 10"
}'

# 結果取得（statement_id は実行時に返される値）
databricks api get /api/2.0/sql/statements/{statement_id} --profile "DEFAULT"
```

### 1.3. コマンドのコツ

1. クエリ実行のフロー
   - `post` でクエリ実行 → `statement_id` が返る
   - `get` で結果取得（`state` が `SUCCEEDED` になるまで待つ）
   - 長いクエリは `sleep` を挟んで再試行

2. エラー対策
   - `state: CLOSED`: 結果取得が遅すぎた場合。早めに `get` を実行
   - `state: FAILED`: SQL エラー。error_message を確認
   - `state: RUNNING`: まだ実行中。少し待ってから再度 `get`
   - タイムアウト: 大量データの場合は `limit` を付けて確認

3. 結果の読み方
   - `data_array`: 実際のデータ（2次元配列）
   - `schema.columns`: カラム名と型情報
   - `total_row_count`: 総件数（limit かかってても表示）
   - `state`: クエリの実行状態

4. パラメータ付きクエリ

```sh
databricks api post /api/2.0/sql/statements --profile "DEFAULT" --json '{
  "warehouse_id": "xxxxxxxxxx",
  "statement": "select * from table where date >= :start_date",
  "parameters": [{"name": "start_date", "value": "2025-01-01", "type": "DATE"}]
}'
```

## 2. Well-Architected Lakehouse フレームワーク

7つの柱で構成される

### 2.1. データおよび AI ガバナンス

データと AI 資産を安全に管理するポリシーと実践。統一されたガバナンスソリューションでデータコピーを最小化。

### 2.2. 相互運用性と使いやすさ

一貫したユーザー体験と外部システムとのシームレスな統合。

### 2.3. 運用上の卓越性

本番環境での継続的な運用を支えるプロセス。

### 2.4. セキュリティ、プライバシー、コンプライアンス

脅威からの保護措置を実装。

### 2.5. 信頼性

障害復旧能力の確保。

### 2.6. パフォーマンス効率

負荷変化への適応性。

### 2.7. コスト最適化

価値提供を最大化するためのコスト管理。

## 3. Unity Catalog

### 3.1. 基本概念

- 「一度定義すれば、どこでも安全」アプローチ
- 複数ワークスペース全体で統一されたアクセス制御ポリシー
- ANSI SQL 準拠の権限管理

### 3.2. オブジェクトモデル

3段階の名前空間: `catalog.schema.table`

1. カタログ層: データの分離単位（部門別など）
2. スキーマ層: テーブル、ビュー、ボリュームなどを含む論理的グループ
3. オブジェクト層: テーブル、ビュー、ボリューム、関数、モデル

### 3.3. 権限管理

- 初期状態ではユーザーはデータにアクセスできない
- 明示的な権限付与が必要
- 権限は上位から下位へ継承（カタログ → スキーマ → テーブル）

```sql
-- 権限確認
SHOW GRANTS ON SCHEMA main.default;

-- 権限付与
GRANT CREATE TABLE ON SCHEMA main.default TO `finance-team`;

-- 権限取消
REVOKE CREATE TABLE ON SCHEMA main.default FROM `finance-team`;
```

### 3.4. ベストプラクティス

- マネージドテーブル/ボリュームを推奨（Delta Lake 形式、フルライフサイクル管理）
- ワークスペース間でのカタログ分離が可能
- 各カタログごとに独立したマネージドストレージロケーション設定を推奨

## 4. データエンジニアリング

### 4.1. Lakeflow ソリューション

データの取り込み、変換、オーケストレーションを統合

- Lakeflow Connect: データ取り込みを簡素化
- Lakeflow Spark Declarative Pipelines (SDP): 宣言型パイプラインフレームワーク
- Lakeflow Jobs: ワークフロー自動化

### 4.2. Delta Lake

- ファイルベースのトランザクションログを備えた Parquet データファイル
- ACID トランザクション
- タイムトラベル機能
- 最適化: 液体クラスタリング、データスキップ、ファイルレイアウト最適化、vacuum

### 4.3. Lakeflow Jobs

タスクタイプ

- ノートブックタスク
- パイプラインタスク
- Python スクリプトタスク

トリガー

- 時間ベース（例: 毎日午前2時）
- イベントベース（新データ到着時）

制限事項

- ワークスペース: 最大2000並行タスク実行
- 保存ジョブ: 最大12000
- ジョブあたりタスク: 最大1000

## 5. 機械学習基盤

### 5.1. MLflow

- 実験追跡とモデル管理の中核ツール
- GenAI 向け専用機能

### 5.2. Feature Store

- 特徴量管理システム
- 自動データパイプラインと特徴量発見

### 5.3. モデルサービング

- カスタムモデルと LLM を REST エンドポイントとしてデプロイ
- 自動スケーリングと GPU サポート

## 6. セキュリティ

### 6.1. 認証とアクセス制御

- SSO 設定
- 多要素認証
- アクセス制御リスト

### 6.2. ネットワークセキュリティ

- プライベート接続
- サーバーレスエグレス制御
- ファイアウォール設定
- VPC 管理

### 6.3. データ暗号化

- 保存時・転送時の暗号化
- カスタマー管理キー
- クラスタ間通信の暗号化
- 認証情報の自動マスキング

## 7. SQL Warehouse

### 7.1. Serverless SQL Warehouse の利点

- Instant and elastic compute
- 自動スケーリング
- 最小限の管理（Databricks がキャパシティ管理を担当）
- 低い総所有コスト

## 8. 詳細ドキュメント

`docs/` ディレクトリに以下の詳細ドキュメントが含まれている

- `unity-catalog.md` - Unity Catalog の詳細と権限管理
- `data-engineering.md` - データエンジニアリングのベストプラクティス
- `machine-learning.md` - 機械学習基盤の詳細
- `security.md` - セキュリティと権限設計
- `well-architected.md` - Well-Architected フレームワーク

## 9. 参考リンク

- 公式ドキュメント: https://docs.databricks.com/
- Unity Catalog: https://docs.databricks.com/en/data-governance/unity-catalog/
- Lakeflow Jobs: https://docs.databricks.com/en/jobs/
- MLflow: https://docs.databricks.com/en/mlflow/
- Delta Lake: https://docs.databricks.com/en/delta/
- セキュリティ: https://docs.databricks.com/en/security/
