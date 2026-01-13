---
source_url: https://docs.databricks.com/en/security/
fetched_at: 2025-12-16
---

# セキュリティと権限設計

## 4つの主要領域

### 1. 認証とアクセス制御

- SSO 設定: SAML 2.0、OAuth 2.0 対応
- 多要素認証 (MFA)
- アクセス制御リスト (ACL)
- サービスプリンシパル

### 2. ネットワークセキュリティ

- プライベート接続: Private Link、VPC エンドポイント
- サーバーレスエグレス制御
- ファイアウォール設定: IP アクセスリスト
- VPC 管理: カスタマー管理 VPC

### 3. データ暗号化

- 保存時の暗号化: AES-256
- 転送時の暗号化: TLS 1.2+
- カスタマー管理キー (CMK)
- クラスタ間通信の暗号化
- 認証情報の自動マスキング

### 4. シークレット管理

- Databricks シークレットスコープ
- Azure Key Vault 統合
- AWS Secrets Manager 統合
- HashiCorp Vault 統合

## 権限設計のベストプラクティス

### 最小権限の原則

ユーザーには業務遂行に必要な最小限の権限のみを付与。

### グループベースの権限管理

```sql
-- グループ作成
CREATE GROUP `data-engineers`;
CREATE GROUP `data-analysts`;
CREATE GROUP `ml-engineers`;

-- グループへの権限付与
GRANT USAGE ON CATALOG production TO `data-analysts`;
GRANT SELECT ON SCHEMA production.analytics TO `data-analysts`;
GRANT ALL PRIVILEGES ON SCHEMA development.sandbox TO `data-engineers`;
```

### 環境分離

- 開発/ステージング/本番の分離
- カタログレベルでの分離推奨

```sql
-- 開発カタログ
CREATE CATALOG development;
GRANT ALL PRIVILEGES ON CATALOG development TO `developers`;

-- 本番カタログ
CREATE CATALOG production;
GRANT USAGE ON CATALOG production TO `data-analysts`;
GRANT SELECT ON CATALOG production TO `data-analysts`;
```

### 機密データの保護

- 動的データマスキング
- 行レベルセキュリティ
- 列レベルセキュリティ

```sql
-- 行レベルセキュリティの例
CREATE FUNCTION region_filter(region STRING)
RETURN IF(IS_MEMBER('global-access'), TRUE, region = CURRENT_USER_ATTRIBUTE('region'));

ALTER TABLE sales SET ROW FILTER region_filter ON (region);
```

## 監査ログ

### システムテーブル

Unity Catalog の監査ログはシステムテーブルで確認可能。

```sql
-- 監査ログの確認
SELECT *
FROM system.access.audit
WHERE event_time > CURRENT_DATE - INTERVAL 7 DAYS
ORDER BY event_time DESC;
```

### 監査対象イベント

- データアクセス
- 権限変更
- オブジェクト作成/削除
- ログイン/ログアウト

## コンプライアンス

対応フレームワーク:

- SOC 2 Type II
- ISO 27001
- GDPR
- HIPAA
- PCI DSS
- FedRAMP
