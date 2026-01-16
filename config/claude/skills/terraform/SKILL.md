---
name: terraform
description: Terraform Expert Engineer Skill - Comprehensive guide for Infrastructure as Code, resource management, module design, and state management
---

# Terraform Expert Engineer Skill

This skill provides a comprehensive guide for Terraform development.

## 1. Terraform CLI Basic Commands

### 1.1. Initialization and Planning

```sh
# Initialize workspace (download providers)
terraform init

# Initialize with backend config
terraform init -backend-config="bucket=my-terraform-state"

# Check execution plan
terraform plan

# Save execution plan to file
terraform plan -out=tfplan

# Plan specific resource only
terraform plan -target=aws_instance.example
```

### 1.2. Apply and Destroy

```sh
# Apply changes
terraform apply

# Apply saved plan
terraform apply tfplan

# Auto-approve apply (for CI/CD)
terraform apply -auto-approve

# Destroy resources
terraform destroy

# Destroy specific resource only
terraform destroy -target=aws_instance.example
```

### 1.3. State Management

```sh
# Check state
terraform state list

# Show resource details
terraform state show aws_instance.example

# Move resource (for refactoring)
terraform state mv aws_instance.old aws_instance.new

# Import existing resource
terraform import aws_instance.example i-1234567890abcdef0

# Remove resource from state (keeps actual resource)
terraform state rm aws_instance.example
```

### 1.4. Other Useful Commands

```sh
# Validate configuration
terraform validate

# Format
terraform fmt

# Format recursively
terraform fmt -recursive

# Check outputs
terraform output

# Output in JSON format
terraform output -json

# Interactive console (for testing expressions)
terraform console

# Lock providers
terraform providers lock -platform=linux_amd64 -platform=darwin_amd64
```

## 2. Resource Management

### 2.1. Basic Resource Block Structure

```hcl
resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  tags = {
    Name = "example-instance"
  }
}
```

### 2.2. Meta-arguments

- `depends_on`: Explicit dependencies
- `count`: Resource replication (index-based)
- `for_each`: Resource replication (key-based)
- `provider`: Specify alternate provider
- `lifecycle`: Lifecycle control

### 2.3. Lifecycle Settings

```hcl
resource "aws_instance" "example" {
  # ...

  lifecycle {
    create_before_destroy = true  # Create new first on replacement
    prevent_destroy       = true  # Prevent deletion
    ignore_changes        = [tags] # Attributes to ignore changes
    replace_triggered_by  = [null_resource.trigger.id]
  }
}
```

## 3. Module Design

### 3.1. Module Invocation

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "my-vpc"
  cidr = "10.0.0.0/16"
}
```

### 3.2. Module Source Types

- Local path: `./modules/vpc`
- Terraform Registry: `hashicorp/consul/aws`
- GitHub: `github.com/hashicorp/example`
- S3: `s3::https://s3-eu-west-1.amazonaws.com/bucket/module.zip`

### 3.3. Module Best Practices

- Standard file structure: `main.tf`, `variables.tf`, `outputs.tf`
- Document with README.md
- Set meaningful default values
- Validate inputs with validation blocks

## 4. State Management

### 4.1. Remote Backend Configuration

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

### 4.2. State Management Best Practices

- Use remote backend (required for team development)
- Enable state locking (prevent concurrent execution)
- Enable encryption
- Do not directly edit state file (use `terraform state` commands)
- Separate state files per environment

## 5. Variables and Outputs

### 5.1. Input Variables

```hcl
variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t2.micro"

  validation {
    condition     = contains(["t2.micro", "t2.small", "t2.medium"], var.instance_type)
    error_message = "Please specify an allowed instance type"
  }
}
```

### 5.2. Variable Setting Methods (Priority Order)

1. Command line `-var`, `-var-file`
2. `*.auto.tfvars` files
3. `terraform.tfvars.json`
4. `terraform.tfvars`
5. Environment variables `TF_VAR_*`
6. Default values

### 5.3. Sensitive Data Handling

```hcl
variable "db_password" {
  type      = string
  sensitive = true  # Mask in output
}

output "connection_string" {
  value     = "postgres://user:${var.db_password}@host/db"
  sensitive = true  # Output contains sensitive data
}
```

Note: Sensitive data is stored in plaintext in state files.
Remote backend encryption or HCP Terraform recommended.

## 6. Providers

### 6.1. Provider Declaration

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}
```

### 6.2. Multiple Providers

```hcl
provider "aws" {
  alias  = "us_east"
  region = "us-east-1"
}

provider "aws" {
  alias  = "ap_northeast"
  region = "ap-northeast-1"
}

resource "aws_instance" "us" {
  provider = aws.us_east
  # ...
}
```

## 7. Built-in Functions

### 7.1. Common Functions

```hcl
# String operations
join("-", ["foo", "bar"])          # "foo-bar"
split(",", "a,b,c")                # ["a", "b", "c"]
format("Hello, %s!", "World")      # "Hello, World!"

# Collection operations
length(["a", "b", "c"])            # 3
lookup(map, key, default)          # Get value from map
merge(map1, map2)                  # Merge maps
flatten([["a"], ["b", "c"]])       # ["a", "b", "c"]

# Type conversions
tostring(123)                      # "123"
tolist(set)                        # Set to list
tomap(object)                      # Object to map

# Conditional expressions
coalesce("", "default")            # "default" (first non-empty value)
try(expression, fallback)          # Fallback on error
```

## 8. HCP Terraform / Terraform Cloud

### 8.1. Key Features

- Remote state management (encryption, versioning)
- Team collaboration
- Policy enforcement (Sentinel)
- Private module registry
- VCS integration (GitHub, GitLab, etc.)
- Cost estimation

### 8.2. Workspace Configuration

```hcl
terraform {
  cloud {
    organization = "my-org"

    workspaces {
      name = "my-workspace"
    }
  }
}
```

## 9. Security Best Practices

### 9.1. Credential Management

- Do not hardcode
- Use environment variables or auth files
- IAM roles / service accounts recommended
- HashiCorp Vault integration

### 9.2. State File Security

- Use encrypted backend
- Set appropriate access controls
- Add `.terraform/` to `.gitignore`
- Add `*.tfvars` to `.gitignore` (if contains sensitive info)

## 10. Detailed Documentation

See `docs/` directory for detailed documentation:

- `language-overview.md` - Terraform language overview
- `resources.md` - Resource management details
- `modules.md` - Module design
- `state.md` - State management
- `providers.md` - Provider configuration
- `variables.md` - Variables and outputs
- `expressions.md` - Expressions and functions
- `lifecycle.md` - Lifecycle control
- `backends.md` - Backend configuration
- `sensitive-data.md` - Sensitive data handling
- `data-sources.md` - Data sources
- `hcp-terraform.md` - HCP Terraform / Terraform Cloud

## 11. Reference Links

- Official docs: <https://developer.hashicorp.com/terraform/docs>
- Language reference: <https://developer.hashicorp.com/terraform/language>
- CLI reference: <https://developer.hashicorp.com/terraform/cli>
- Provider registry: <https://registry.terraform.io/>
- Module registry: <https://registry.terraform.io/browse/modules>
- HCP Terraform: <https://developer.hashicorp.com/terraform/cloud-docs>
