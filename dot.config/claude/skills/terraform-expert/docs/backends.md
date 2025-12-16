---
source_url: https://developer.hashicorp.com/terraform/language/settings/backends
fetched_at: 2025-12-16
---

# Terraform Backends: Configuration and State Storage

## Overview

Terraform backends define where state data is persisted. They enable multiple people to access infrastructure state and collaborate on resource management. You can integrate with HCP Terraform or configure a backend block to store state remotely.

## Key Limitations

- A configuration can only include one backend block
- Backend blocks cannot reference named values like variables or locals
- Values within backend blocks cannot be referenced elsewhere in configuration

## Backend Types

Terraform includes several built-in backend types that serve as remote storage for state files. Some support state locking to prevent conflicts during operations. Available backends include:

- **local** (default) - stores state as a local file on disk
- **remote** - HCP Terraform integration
- **s3** - Amazon S3 storage
- **azurerm** - Azure storage
- **gcs** - Google Cloud Storage
- **consul** - HashiCorp Consul
- **kubernetes** - Kubernetes secrets
- **http** - HTTP endpoints
- **postgresql** - PostgreSQL databases
- **oss** - Alibaba Object Storage Service
- **oci** - Oracle Cloud Infrastructure

## Configuration Requirements

Backend arguments are type-specific and determine where and how state is stored. "We do not recommend including access credentials directly in the configuration." Instead, use environment variables or credential files conventional to your target system.

## S3 バックエンドの設定例

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "ap-northeast-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

## Azure バックエンドの設定例

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstatestorage"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}
```

## GCS バックエンドの設定例

```hcl
terraform {
  backend "gcs" {
    bucket = "my-terraform-state"
    prefix = "prod"
  }
}
```

## Initialization

Running `terraform init` validates and configures the backend. This creates a `.terraform/` directory containing backend configuration and authentication parameters. This directory should be excluded from version control due to potential credential exposure.

## Partial Configuration

You can omit backend arguments if they're provided during initialization through:

- Configuration files with `-backend-config=PATH`
- Command-line key/value pairs
- Interactive prompts

```sh
# 部分設定を使用した初期化
terraform init -backend-config="bucket=my-bucket" -backend-config="key=prod/terraform.tfstate"

# 設定ファイルを使用
terraform init -backend-config=backend.hcl
```

## State Migration

When changing backends, Terraform prompts you to migrate existing state to the new configuration, allowing seamless backend switching without data loss.

```sh
# バックエンド変更後の再初期化
terraform init -migrate-state

# 状態を再設定
terraform init -reconfigure
```
