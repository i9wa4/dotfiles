---
source_url: https://developer.hashicorp.com/terraform/language/values/outputs
fetched_at: 2025-12-16
---

# Terraform Output Values: Complete Guide

## Overview

Output blocks in Terraform expose infrastructure information through multiple channels: CLI display, HCP Terraform workspace views, remote state access, and automation tool integration.

## Defining Outputs

You structure outputs with three main components:

**Basic syntax:**

```hcl
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.web.id
}
```

The `value` argument accepts any valid Terraform expression, allowing flexible data exposure from your resources.

## Accessing Output Values

**Root module outputs** display automatically in CLI after applying configuration and appear on HCP Terraform workspace overview pages.

**Child module outputs** use the `module.<CHILD_MODULE_NAME>.<OUTPUT_NAME>` pattern for parent module access, enabling data flow between configuration layers:

```hcl
records = [module.web_server.instance_ip]
dimensions = {
  InstanceId = module.web_server.instance_id
}
```

**Remote state access** allows other Terraform configurations to retrieve outputs via the `terraform_remote_state` data source.

## Handling Sensitive Data

Use the `sensitive` argument to prevent displaying sensitive values in CLI output:

```hcl
output "database_password" {
  value       = aws_db_instance.main.password
  sensitive   = true
}
```

When accessed directly, sensitive outputs show as `<sensitive>` rather than actual values.

**Important caveat:** "Terraform stores the values of `sensitive` outputs in your state. If you use the `terraform output` CLI command with the `-json` or `-raw` flags, Terraform displays sensitive outputs in plain text."

The `ephemeral` argument further restricts sensitive data by omitting values from state and plan files entirely.

## 出力の使用例

```hcl
# 基本的な出力
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

# 複数の値を出力
output "subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

# オブジェクトとして出力
output "instance_info" {
  description = "Information about the instance"
  value = {
    id         = aws_instance.web.id
    public_ip  = aws_instance.web.public_ip
    private_ip = aws_instance.web.private_ip
  }
}

# 条件付き出力
output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = var.create_lb ? aws_lb.main[0].dns_name : null
}
```

## CLI での出力確認

```sh
# すべての出力を表示
terraform output

# 特定の出力を表示
terraform output instance_id

# JSON 形式で出力
terraform output -json

# 生の値を取得（スクリプト向け）
terraform output -raw instance_id
```
