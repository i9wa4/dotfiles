---
source_url: https://developer.hashicorp.com/terraform/language/expressions
fetched_at: 2025-12-16
---

# Terraform Expressions Overview

## Definition

"Expressions refer to or compute values within a configuration." The simplest forms are literal values like `"hello"` or `5`, but Terraform supports complex expressions including resource data references, arithmetic, conditionals, and built-in functions.

## Key Expression Types

**Types and Values**: Terraform expressions resolve to specific data types with corresponding literal syntax for representing those values.

**Strings and Templates**: The language supports string literals with interpolation sequences and template directives for dynamic content generation.

**References to Values**: Named values like variables and resource attributes can be referenced within expressions.

**Operators**: Arithmetic, comparison, and logical operators enable value manipulation and evaluation.

**Function Calls**: Terraform provides built-in functions accessible through standard function call syntax.

**Conditional Expressions**: The ternary operator format `<CONDITION> ? <TRUE VAL> : <FALSE VAL>` selects between two values based on boolean conditions.

**For Expressions**: These transform complex types into other complex types, exemplified by `[for s in var.list : upper(s)]`.

**Splat Expressions**: Extract simplified collections from complex expressions using syntax like `var.list[*].id`.

## 式の例

### 文字列補間

```hcl
resource "aws_instance" "web" {
  tags = {
    Name = "web-${var.environment}-${count.index}"
  }
}
```

### 条件式

```hcl
resource "aws_instance" "web" {
  instance_type = var.environment == "production" ? "t2.large" : "t2.micro"
}
```

### for 式

```hcl
# リストの変換
output "upper_names" {
  value = [for name in var.names : upper(name)]
}

# フィルタリング
output "short_names" {
  value = [for name in var.names : name if length(name) < 5]
}

# マップの生成
output "name_map" {
  value = {for name in var.names : name => upper(name)}
}
```

### Splat 式

```hcl
# すべてのインスタンスの ID を取得
output "instance_ids" {
  value = aws_instance.web[*].id
}

# 属性アクセス
output "private_ips" {
  value = aws_instance.web[*].private_ip
}
```

### 動的ブロック

```hcl
resource "aws_security_group" "web" {
  name = "web-sg"

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
}
```

## Testing Expressions

You can experiment with Terraform expressions using the `terraform console` command, which provides an interactive environment for testing expression behavior.

```sh
$ terraform console
> upper("hello")
"HELLO"
> length(["a", "b", "c"])
3
> var.environment == "prod" ? "large" : "small"
"small"
```
