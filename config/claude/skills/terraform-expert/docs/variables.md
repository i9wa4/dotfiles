---
source_url: https://developer.hashicorp.com/terraform/language/values/variables
fetched_at: 2025-12-16
---

# Terraform Input Variables: Comprehensive Guide

## Overview

Input variables allow module consumers to customize module behavior without modifying source code. They enable flexible, reusable infrastructure configurations.

## Variable Declaration

Variables are defined using `variable` blocks in your configuration:

```hcl
variable "instance_type" {
  type        = string
  description = "EC2 instance type for the web server"
  default     = "t2.micro"
}
```

## Core Components

**Type**: Specifies the variable's data type (string, number, bool, list, map, etc.)

**Description**: Explains the variable's purpose and usage

**Default**: Provides a fallback value if none is supplied; if omitted, Terraform prompts for input

## Variable Types

```hcl
# プリミティブ型
variable "name" {
  type = string
}

variable "count" {
  type = number
}

variable "enabled" {
  type = bool
}

# コレクション型
variable "availability_zones" {
  type = list(string)
}

variable "tags" {
  type = map(string)
}

variable "settings" {
  type = set(string)
}

# 構造型
variable "server_config" {
  type = object({
    name          = string
    instance_type = string
    tags          = map(string)
  })
}

variable "servers" {
  type = list(object({
    name = string
    size = number
  }))
}
```

## Variable References

Access variables throughout your configuration using `var.<NAME>` syntax:

```hcl
resource "aws_instance" "web" {
  instance_type = var.instance_type
}
```

## Validation

Optional `validation` blocks enforce requirements:

```hcl
variable "environment" {
  type = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "image_id" {
  type = string

  validation {
    condition     = can(regex("^ami-", var.image_id))
    error_message = "Image ID must start with 'ami-'."
  }
}
```

## Sensitive Data

Protect sensitive values using the `sensitive` argument to prevent CLI output display of passwords or API keys.

```hcl
variable "db_password" {
  type      = string
  sensitive = true
}
```

## Assignment Methods (Priority Order)

1. Command-line flags (`-var`, `-var-file`)
2. `*.auto.tfvars` files (lexical order)
3. `terraform.tfvars.json`
4. `terraform.tfvars`
5. Environment variables (`TF_VAR_` prefix)
6. Variable defaults

## 変数の設定例

```sh
# コマンドライン
terraform apply -var="instance_type=t2.small"

# 変数ファイル
terraform apply -var-file="production.tfvars"

# 環境変数
export TF_VAR_instance_type="t2.small"
terraform apply
```

## terraform.tfvars の例

```hcl
# terraform.tfvars
instance_type = "t2.micro"
environment   = "production"

tags = {
  Project = "my-project"
  Owner   = "team-a"
}

availability_zones = [
  "ap-northeast-1a",
  "ap-northeast-1c",
]
```
