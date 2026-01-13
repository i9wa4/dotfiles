---
source_url: https://developer.hashicorp.com/terraform/tutorials/configuration-language/sensitive-variables
fetched_at: 2025-12-16
---

# Handling Sensitive Variables in Terraform

## Core Concept

Terraform allows you to mark input variables as sensitive to prevent accidental exposure of secrets like passwords, API tokens, and personally identifiable information (PII).

## Declaration and Usage

To protect sensitive data, declare variables with the `sensitive = true` flag:

```hcl
variable "db_password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
}
```

When marked as sensitive, Terraform redacts these values from plan and apply output, displaying them as `(sensitive value)` instead of actual credentials.

## Setting Variable Values

### Method 1: Environment Variables

For Terraform Community Edition, use the `TF_VAR_<VARIABLE_NAME>` pattern:

```bash
export TF_VAR_db_password=mypassword
```

**Important caveat:** "When using environment variables to set sensitive values, keep in mind that those values will be in your environment and command-line history."

### Method 2: .tfvars Files

Create separate files like `secret.tfvars` to organize sensitive values, then apply with:

```bash
terraform apply -var-file="secret.tfvars"
```

**Best practice:** Add `*.tfvars` patterns to `.gitignore` to prevent committing secrets to version control.

## Critical Security Considerations

**State File Protection:** Local state files store sensitive values as plain text. "Terraform stores the state as plain text, including variable values, even if you have flagged them as `sensitive`."

To secure state:

- Use HCP Terraform, which encrypts all variable values at rest
- Consider HashiCorp Vault for centralized secrets management
- Restrict access to state file storage

## Output Handling

Outputs referencing sensitive variables must also be marked sensitive:

```hcl
output "db_connect_string" {
  value     = "Server=${aws_db_instance.database.address}..."
  sensitive = true
}
```

Without this flag, Terraform raises an error to prevent accidental exposure.

## 機密データ管理のベストプラクティス

### 1. .gitignore の設定

```gitignore
# 状態ファイル
*.tfstate
*.tfstate.*

# 機密情報を含む可能性のあるファイル
*.tfvars
!example.tfvars

# Terraform の作業ディレクトリ
.terraform/
```

### 2. HashiCorp Vault との連携

```hcl
provider "vault" {
  address = "https://vault.example.com"
}

data "vault_generic_secret" "db" {
  path = "secret/database"
}

resource "aws_db_instance" "main" {
  password = data.vault_generic_secret.db.data["password"]
}
```

### 3. AWS Secrets Manager との連携

```hcl
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "prod/db/password"
}

resource "aws_db_instance" "main" {
  password = jsondecode(data.aws_secretsmanager_secret_version.db_password.secret_string)["password"]
}
```

### 4. 環境変数を使用した認証

```hcl
# provider ブロックで認証情報を直接指定しない
provider "aws" {
  region = "ap-northeast-1"
  # AWS_ACCESS_KEY_ID と AWS_SECRET_ACCESS_KEY 環境変数を使用
}
```
