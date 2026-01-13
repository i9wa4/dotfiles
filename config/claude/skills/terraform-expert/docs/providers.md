---
source_url: https://developer.hashicorp.com/terraform/language/providers
fetched_at: 2025-12-16
---

# Terraform Providers Overview

## Core Concepts

Terraform providers are plugins that enable infrastructure management. According to the documentation, "Terraform relies on plugins called providers to interact with cloud providers, SaaS providers, and other APIs."

## What Providers Do

Each provider furnishes resource types and data sources for managing infrastructure. The system requires providers—without them, Terraform cannot manage any infrastructure. Some providers target specific platforms (cloud or self-hosted), while others offer local utilities like random number generation.

## Provider Sources

Providers distribute independently from Terraform with their own release schedules. The Terraform Registry serves as the primary directory for publicly accessible providers, hosting solutions for major infrastructure platforms.

## Configuration Requirements

Configurations must declare required providers so Terraform can locate and install them. Some providers need configuration before use, including endpoint URLs or cloud region specifications.

## プロバイダーの宣言

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  required_version = ">= 1.5.0"
}

provider "aws" {
  region = "ap-northeast-1"

  default_tags {
    tags = {
      Environment = "production"
      ManagedBy   = "terraform"
    }
  }
}
```

## Installation

- **HCP Terraform and Enterprise**: Install providers automatically during runs
- **Terraform CLI**: Locates and installs providers during initialization, supporting automatic downloads, local mirrors, or caching via `plugin_cache_dir`

## Provider Tiers

The Registry categorizes providers by maintainer:

- **Official**: Owned by HashiCorp (namespace: hashicorp, IBM, ansible)
- **Partner Premier**: Third-party qualified partners
- **Partner**: Validated third-party maintainers
- **Community**: Individual or group maintainers
- **Archived**: No longer actively maintained

## 複数プロバイダーの使用（エイリアス）

```hcl
provider "aws" {
  alias  = "tokyo"
  region = "ap-northeast-1"
}

provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}

resource "aws_instance" "tokyo_server" {
  provider = aws.tokyo
  # ...
}

resource "aws_instance" "virginia_server" {
  provider = aws.virginia
  # ...
}
```

## バージョン制約

```hcl
# 厳密なバージョン
version = "5.0.0"

# 互換性のあるバージョン（5.x）
version = "~> 5.0"

# 範囲指定
version = ">= 5.0.0, < 6.0.0"
```

## 依存関係ロックファイル

`.terraform.lock.hcl` でプロバイダーのバージョンをロック:

```sh
# プラットフォーム用にロックファイルを更新
terraform providers lock -platform=linux_amd64 -platform=darwin_amd64
```
