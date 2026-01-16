---
source_url: https://docs.databricks.com/en/data-engineering/
fetched_at: 2025-12-16
---

# データエンジニアリング

## Lakeflow ソリューション

Databricks は「Lakeflow」という包括的なソリューションを提供し、データの取り込み、変換、オーケストレーションを統合。

### Lakeflow Connect

データ取り込みを簡素化し、エンタープライズアプリケーション、データベース、クラウドストレージなど多様なソースに対応。

- マネージドコネクタ: Databricks が管理
- 標準コネクタ: ユーザーが設定

### Lakeflow Spark Declarative Pipelines (SDP)

バッチおよびストリーミングパイプライン構築の複雑性を軽減する宣言型フレームワーク。

主な機能:

- Flows: データフロー定義
- Streaming tables: ストリーミングテーブル
- Materialized views: マテリアライズドビュー
- Sinks: データ出力先

### Lakeflow Jobs

ワークフロー自動化とプロダクション監視を提供。

## Delta Lake

ファイルベースのトランザクションログを備えた Parquet データファイルを拡張したフォーマット。

### ACID トランザクション

- アトミックなトランザクション
- upsert 操作を使用したマージ
- 選択的な上書き
- スキーマ更新

### タイムトラベル

各テーブル書き込みで新しいバージョンが作成され、トランザクションログを使用して以前のテーブルバージョンをクエリ可能。

```sql
-- 特定バージョンを参照
SELECT * FROM my_table VERSION AS OF 10;

-- 特定タイムスタンプを参照
SELECT * FROM my_table TIMESTAMP AS OF '2025-01-01 00:00:00';

-- テーブル履歴確認
DESCRIBE HISTORY my_table;
```

### 最適化手法

- 液体クラスタリング: 動的なデータ配置最適化
- データスキップ: 不要なファイルのスキップ
- ファイルレイアウト最適化: OPTIMIZE コマンド
- vacuum: 古いファイルの削除

```sql
-- テーブル最適化
OPTIMIZE my_table;

-- Z-ORDER による最適化
OPTIMIZE my_table ZORDER BY (column1, column2);

-- 古いファイル削除
VACUUM my_table RETAIN 168 HOURS;
```

## Lakeflow Jobs 詳細

### タスクタイプ

- ノートブックタスク: Databricks ノートブックを実行
- パイプラインタスク: Lakeflow Spark 宣言型パイプラインを実行
- Python スクリプトタスク: Python ファイルを実行
- SQL タスク: SQL クエリを実行
- dbt タスク: dbt プロジェクトを実行

### トリガー設定

- 時間ベース: cron 式でスケジュール
- イベントベース: クラウドストレージへの新データ到着時

### 依存関係管理

タスクは DAG（有向非環グラフ）で可視化され、条件分岐（if/else）やループ（for each）をサポート。

### 制限事項

- ワークスペース: 最大2000並行タスク実行
- 保存ジョブ: 最大12000
- ジョブあたりタスク: 最大1000

### ベストプラクティス

- システムテーブル経由でジョブ実行とタスク情報を記録してパフォーマンス分析
- 通知設定でジョブ失敗時の対応を自動化
- タスク依存関係を適切に設定して並列実行を最大化
