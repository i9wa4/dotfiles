---
source_url: https://developer.hashicorp.com/terraform/cloud-docs
fetched_at: 2025-12-16
---

# HCP Terraform Overview

**What It Is:**

HCP Terraform (formerly Terraform Cloud) is a collaborative application that enables teams to manage infrastructure as code together. It provides a hosted service at https://app.terraform.io for provisioning and managing cloud resources.

**Key Features:**

- **Remote State Management:** "easy access to shared state and secret data"
- **Access Controls:** Approval workflows for infrastructure changes
- **Private Registry:** Share Terraform modules across teams
- **Policy Enforcement:** "detailed policy controls for governing the contents of Terraform configurations"
- **Audit & Validation:** Standard Edition includes audit logging, continuous validation, and automated drift detection

**Deployment Options:**

1. **Hosted Service:** Free tier for small teams (up to 5 users); paid plans support larger teams with advanced permissions
2. **Self-Hosted:** Terraform Enterprise offers private instances for organizations with stricter security requirements
3. **Regional Options:** HCP Europe variant supports European data residency compliance

**Core Benefits:**

Teams gain consistent, reliable Terraform execution environments with enhanced collaboration capabilities, security controls, and governance mechanisms for managing infrastructure changes at scale.

## ワークスペース設定

```hcl
terraform {
  cloud {
    organization = "my-organization"

    workspaces {
      name = "my-workspace"
    }
  }
}
```

## 複数ワークスペースの管理

```hcl
terraform {
  cloud {
    organization = "my-organization"

    workspaces {
      tags = ["app:web", "env:production"]
    }
  }
}
```

## CLI 駆動ワークフロー

```sh
# HCP Terraform にログイン
terraform login

# ワークスペースを選択
terraform workspace select my-workspace

# リモートで実行
terraform plan
terraform apply
```

## 変数の設定

HCP Terraform では以下の方法で変数を設定:

1. **ワークスペース変数** - UI または API で設定
2. **変数セット** - 複数ワークスペースで共有
3. **環境変数** - プロバイダー認証情報など

## Sentinel ポリシー

```hcl
# すべてのリソースにタグを必須とするポリシー
import "tfplan"

main = rule {
  all tfplan.resources as _, instances {
    all instances as _, r {
      r.applied.tags is not empty
    }
  }
}
```

## VCS 連携

1. GitHub / GitLab / Bitbucket と連携
2. PR 作成時に自動で plan 実行
3. マージ時に自動で apply 実行
4. コスト見積もりの表示

## Run Triggers

ワークスペース間の依存関係を設定:

```
VPC ワークスペース → EKS ワークスペース → アプリケーションワークスペース
```

VPC が更新されると、依存するワークスペースも順次実行される。

## API 活用

```sh
# ワークスペース一覧を取得
curl -H "Authorization: Bearer $TOKEN" \
  "https://app.terraform.io/api/v2/organizations/my-org/workspaces"

# Run を作成
curl -X POST -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/vnd.api+json" \
  -d '{"data":{"type":"runs","relationships":{"workspace":{"data":{"type":"workspaces","id":"ws-xxx"}}}}}' \
  "https://app.terraform.io/api/v2/runs"
```
