---
source_url: https://docs.databricks.com/en/data-governance/unity-catalog/
fetched_at: 2025-12-16
---

# Unity Catalog

## 概要

Unity Catalog は Databricks の統一データガバナンスソリューション。「一度定義すれば、どこでも安全」というアプローチで、複数ワークスペース全体で統一されたアクセス制御ポリシーを管理できる。

## 主な機能

- 監査とデータ系統の追跡: ユーザーレベルのアクセスログを自動キャプチャ
- データ発見: タグ付けと検索機能でアセット探索を支援
- 標準的なセキュリティ: ANSI SQL準拠の権限管理

## オブジェクトモデルと階層構造

`catalog.schema.table` という3段階の名前空間で組織化

1. カタログ層: データの分離単位（部門別など）
2. スキーマ層: テーブル、ビュー、ボリュームなどを含む論理的グループ
3. オブジェクト層: テーブル、ビュー、ボリューム、関数、モデル

## 権限モデル

最小権限の原則に基づき、ユーザーは必要最小限のアクセス権のみ付与される。

### 権限付与者

- メタストア管理者
- オブジェクト所有者
- MANAGE権限保有者

### 権限の継承

権限は上位から下位へ継承される。カタログ→スキーマ→テーブルという階層で、上位レベルの権限は下層のすべてのオブジェクトに自動的に適用。

## 権限管理 SQL

```sql
-- 権限確認
SHOW GRANTS ON SCHEMA main.default;

-- 権限付与
GRANT CREATE TABLE ON SCHEMA main.default TO `finance-team`;
GRANT SELECT ON CATALOG my_catalog TO `data-analysts`;
GRANT USAGE ON SCHEMA main.default TO `reporting-team`;

-- 権限取消
REVOKE CREATE TABLE ON SCHEMA main.default FROM `finance-team`;
```

## 主要な権限タイプ

- SELECT: データの読み取り
- INSERT: データの挿入
- UPDATE: データの更新
- DELETE: データの削除
- CREATE TABLE: テーブル作成
- CREATE VIEW: ビュー作成
- USAGE: スキーマ/カタログへのアクセス
- MANAGE: 権限管理

## ベストプラクティス

- マネージドテーブル/ボリュームを推奨（Delta Lake 形式、フルライフサイクル管理）
- ワークスペース間でのカタログ分離が可能
- 各カタログごとに独立したマネージドストレージロケーション設定を推奨
- グループベースの権限管理を推奨（個人への直接付与を避ける）
