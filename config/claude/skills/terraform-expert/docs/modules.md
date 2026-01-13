---
source_url: https://developer.hashicorp.com/terraform/language/modules
fetched_at: 2025-12-16
---

# Terraform Modules Overview

## What Are Modules?

A module is a collection of resources that Terraform manages together. They enable you to codify reusable infrastructure patterns and standardize provisioning across your organization.

## Module Hierarchy

Terraform configurations operate within a hierarchical structure:

- **Root Module**: The configuration files in your workspace's root directory
- **Child Modules**: Modules called via `module` blocks from the root module
- **Nested Modules**: Child modules can themselves call additional child modules

The root module integrates child module resources into the workspace and manages them as part of the overall configuration.

## Module Sources

Terraform can load modules from multiple locations:

1. **Local file system** - Modules stored in your project directory
2. **Terraform Registry** - The public registry hosts community, partner, and HashiCorp-maintained modules
3. **VCS repositories** - GitHub and other version control systems
4. **Private registries** - HCP Terraform and Terraform Enterprise support internal module sharing

## モジュールの呼び出し

```hcl
# ローカルモジュール
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr = "10.0.0.0/16"
  environment = "production"
}

# Terraform Registry からのモジュール
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "my-cluster"
  cluster_version = "1.28"
}

# GitHub からのモジュール
module "example" {
  source = "github.com/hashicorp/example?ref=v1.0.0"
}
```

## Implementation Workflow

The module lifecycle follows three phases:

1. **Develop**: Module developers structure resources following standard conventions with documentation
2. **Distribute**: Publish modules to the public registry, private registry, or other supported sources
3. **Provision**: Consumers reference modules in their configurations using `module` blocks

## モジュールの標準構成

```
modules/
└── vpc/
    ├── main.tf         # リソース定義
    ├── variables.tf    # 入力変数
    ├── outputs.tf      # 出力値
    ├── versions.tf     # バージョン制約
    └── README.md       # ドキュメント
```

## モジュール出力の参照

```hcl
# 子モジュールの出力を参照
resource "aws_instance" "web" {
  subnet_id = module.vpc.private_subnet_ids[0]
}

# 出力値として公開
output "vpc_id" {
  value = module.vpc.vpc_id
}
```

## Key Practices

When repeatedly provisioning similar resource collections, modularization provides standardization and predictability. This approach reduces configuration duplication and accelerates infrastructure deployment.

### ベストプラクティス

- 1つのモジュールは1つの責務を持つ
- 意味のあるデフォルト値を設定
- 入力変数にバリデーションを追加
- 出力値で必要な情報を公開
- README.md でドキュメント化
- セマンティックバージョニングを使用
