---
source_url: https://developer.hashicorp.com/terraform/language/data-sources
fetched_at: 2025-12-16
---

# Terraform Data Sources: Comprehensive Overview

## Core Concept

Data sources in Terraform enable you to query and retrieve information from external systems without creating or modifying resources. As stated in the documentation, "Data sources fetch data from the provider, but do not create or modify resources."

## Declaration and Structure

To use a data source, implement a `data` block specifying the source type and label:

```hcl
data "aws_ami" "example" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  owners = ["amazon"]
}
```

Access retrieved values using the syntax: `data.<TYPE>.<LABEL>.<ATTRIBUTE>` (e.g., `data.aws_ami.example.id`).

## Query Constraints

Configure arguments within data blocks to filter results. For instance, you can constrain queries to "the most recent AMI owned by the current user" with specific tag requirements.

Use expressions and dynamic language features to make constraints flexible and adaptable.

## Execution Timing

Terraform processes data sources during planning phase when possible. However, it defers reading to the apply phase when arguments reference:

- Resources configured to change in the current plan
- Custom conditions depending on changing resources
- Values requiring computation during apply

## Advanced Configuration

**Dependencies**: Use `depends_on` meta-arguments to control query sequencing when implicit dependency detection is insufficient.

**Custom Conditions**: Implement `precondition` and `postcondition` blocks within lifecycle configurations to validate data source behavior.

**Multiple Instances**: Leverage `count` and `for_each` meta-arguments to create multiple data source instances, indexed separately.

**Provider Aliasing**: Specify alternate provider configurations to query data from different regions or accounts.

## よく使うデータソースの例

### AWS リージョンとアカウント情報

```hcl
data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}
```

### 既存の VPC を参照

```hcl
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["main-vpc"]
  }
}

resource "aws_subnet" "private" {
  vpc_id = data.aws_vpc.main.id
  # ...
}
```

### IAM ポリシードキュメント

```hcl
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "example" {
  name               = "example-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}
```

### 利用可能な AZ を取得

```hcl
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "private" {
  count             = length(data.aws_availability_zones.available.names)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  # ...
}
```

## Specialized Data Sources

Certain data sources generate computed data existing only during Terraform operations, including template rendering, local file reading, and AWS IAM policy generation.

```hcl
# ローカルファイルの読み込み
data "local_file" "config" {
  filename = "${path.module}/config.json"
}

# テンプレートの生成
data "template_file" "user_data" {
  template = file("${path.module}/user_data.sh.tpl")

  vars = {
    environment = var.environment
  }
}
```
