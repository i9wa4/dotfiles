---
source_url: https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle
fetched_at: 2025-12-16
---

# Terraform Lifecycle Meta-Argument Overview

The `lifecycle` block customizes how Terraform handles resource operations during plan and apply phases. Here's a summary of key rules:

## create_before_destroy

This rule instructs Terraform to "create a replacement resource before destroying the current resource" when API limitations prevent in-place updates. It's opt-in because concurrent resource existence may violate naming constraints or other provider-specific requirements. When enabled on a resource, Terraform automatically applies this behavior to all its dependencies, storing the configuration in state files.

```hcl
resource "aws_instance" "web" {
  # ...

  lifecycle {
    create_before_destroy = true
  }
}
```

## prevent_destroy

Setting this to `true` causes Terraform to reject any plan that would eliminate the infrastructure object, returning an error. The documentation notes: "Use this rule as protection against accidentally replacing objects that may be costly to reproduce, such as database instances." However, this mechanism doesn't prevent destruction if you remove the resource's entire configuration—you must use separate state management procedures for that scenario.

```hcl
resource "aws_db_instance" "main" {
  # ...

  lifecycle {
    prevent_destroy = true
  }
}
```

## ignore_changes

By default, Terraform detects and updates any infrastructure differences. This rule lets you specify attributes to exclude from update checks. The tool "considers the arguments corresponding to the given attribute names when planning a `create` operation, but are ignored when planning an `update` operation." You can target specific map/list elements or use the `all` keyword to prevent all update proposals.

```hcl
resource "aws_instance" "web" {
  # ...

  lifecycle {
    # 特定の属性を無視
    ignore_changes = [
      tags,
      user_data,
    ]
  }
}

resource "aws_autoscaling_group" "asg" {
  # ...

  lifecycle {
    # すべての変更を無視
    ignore_changes = all
  }
}
```

## replace_triggered_by

This rule triggers resource replacement "when any of the referenced resources or specified attributes change." It accepts a list of managed resource expressions—notably, it cannot reference plain values like variables or locals, though the `terraform_data` resource provides a workaround.

```hcl
resource "aws_instance" "web" {
  # ...

  lifecycle {
    replace_triggered_by = [
      null_resource.always_replace.id,
      aws_ami.custom.id,
    ]
  }
}

resource "null_resource" "always_replace" {
  triggers = {
    timestamp = timestamp()
  }
}
```

## precondition と postcondition

リソースの前提条件と事後条件を検証:

```hcl
resource "aws_instance" "web" {
  instance_type = var.instance_type
  ami           = var.ami_id

  lifecycle {
    precondition {
      condition     = data.aws_ami.selected.architecture == "x86_64"
      error_message = "AMI must be x86_64 architecture."
    }

    postcondition {
      condition     = self.public_ip != ""
      error_message = "Instance must have a public IP address."
    }
  }
}
```
