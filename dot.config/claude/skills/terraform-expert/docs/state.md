---
source_url: https://developer.hashicorp.com/terraform/language/state
fetched_at: 2025-12-16
---

# Terraform State Overview

## Core Purpose

Terraform state serves as a critical data store that maps real-world cloud resources to your configuration code. According to the documentation, "Terraform must store state about your managed infrastructure and configuration. This state is used by Terraform to map real world resources to your configuration, keep track of metadata, and to improve performance for large infrastructures."

## Default Storage

By default, state information is persisted in a local JSON file named `terraform.tfstate`. However, HashiCorp recommends moving this to a remote backend for team collaboration and security.

## State Management Best Practices

**Remote Storage**: The documentation advises "storing it in HCP Terraform to version, encrypt, and securely share it with your team," which provides centralized management and audit trails.

**CLI-Based Modifications**: Rather than directly editing state files, use the `terraform state` command. This approach protects against format changes and provides a stable interface across Terraform versions.

**One-to-One Mapping**: Terraform expects a strict one-to-one relationship between configured resources and remote objects. When using commands like `terraform import` or `terraform state rm`, you must manually ensure this relationship remains consistent.

## 状態管理コマンド

```sh
# 状態内のリソース一覧
terraform state list

# リソースの詳細表示
terraform state show aws_instance.example

# リソースの移動（リファクタリング時）
terraform state mv aws_instance.old aws_instance.new

# 状態からリソースを削除（実リソースは残る）
terraform state rm aws_instance.example

# リソースのインポート
terraform import aws_instance.example i-1234567890abcdef0

# 状態をリフレッシュ（実リソースと同期）
terraform refresh
```

## Output Formats

State information can be exported as JSON through:

- `terraform output` command with `-json` flag
- `terraform show` command with `-json` flag

These outputs enable external systems to consume infrastructure state without running Terraform directly.

## リモート状態の参照

他のワークスペースの状態を参照:

```hcl
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "my-terraform-state"
    key    = "vpc/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

resource "aws_instance" "web" {
  subnet_id = data.terraform_remote_state.vpc.outputs.private_subnet_id
}
```

## 状態のロック

同時実行を防ぐためのロック機能:

- S3 バックエンド: DynamoDB テーブルを使用
- Azure: Blob Storage のリースを使用
- GCS: オブジェクトの世代番号を使用

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "terraform-locks"  # ロック用テーブル
    encrypt        = true
  }
}
```
