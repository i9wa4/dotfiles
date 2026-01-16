---
source_url: https://developer.hashicorp.com/terraform/language/resources
fetched_at: 2025-12-16
---

# Terraform Resources: Create and Manage Overview

## Resource Definition

A **resource** represents any infrastructure object you want to provision and manage with Terraform, such as virtual networks, compute instances, or DNS records. The available resource types depend on the providers you install.

## Core Workflow

### 1. Write Resource Configuration

Add a `resource` block to your Terraform configuration file with necessary arguments. Most arguments control resource-specific behavior, while **meta-arguments** are Terraform-specific settings that determine creation and management approaches.

```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  tags = {
    Name        = "web-server"
    Environment = "production"
  }
}
```

### 2. Initialize Your Workspace

Before applying configuration, initialize the workspace to download and install required providers and modules. Reinitialization is necessary when changing providers or modules in existing projects.

```sh
terraform init
```

### 3. Apply Configuration

Using the Terraform CLI's apply command executes these operations:

- "Creates resources in the configuration that do not yet exist as real infrastructure objects"
- "Destroys resources that exist in the state but no longer exist in the configuration"
- Updates resources in-place when arguments change
- Destroys and recreates resources when in-place updates aren't possible due to API limitations
- Synchronizes the state file with configuration and actual infrastructure

## Resource Management

As infrastructure needs evolve, you can:

- **Create modules** to collect resources into reusable components
- **Refactor modules** for moving and renaming sources
- **Remove from state** without destroying actual infrastructure
- **Destroy resources** to remove both state and actual infrastructure

## Meta-Arguments

すべてのリソースタイプで使用できる特別な引数:

- `depends_on` - 明示的な依存関係の宣言
- `count` - 同一リソースの複数作成（インデックスベース）
- `for_each` - 同一リソースの複数作成（キーベース）
- `provider` - デフォルト以外のプロバイダーの指定
- `lifecycle` - ライフサイクル動作のカスタマイズ

### count の使用例

```hcl
resource "aws_instance" "server" {
  count = 3

  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  tags = {
    Name = "server-${count.index}"
  }
}
```

### for_each の使用例

```hcl
resource "aws_iam_user" "users" {
  for_each = toset(["alice", "bob", "charlie"])

  name = each.key
}
```

## Additional Capabilities

Providers enable reading data from existing infrastructure through data sources, allowing you to reference infrastructure without provisioning new objects.
