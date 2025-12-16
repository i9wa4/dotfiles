---
name: terraform-expert
description: Terraform エキスパートエンジニアスキル - Infrastructure as Code、リソース管理、モジュール設計、状態管理に関する包括的なガイドを提供
---

# Terraform Expert Engineer Skill

このスキルは Terraform 開発に関する包括的なガイドを提供する。

## 1. Terraform CLI の基本コマンド

### 1.1. 初期化と計画

```sh
# ワークスペースの初期化（プロバイダーのダウンロード）
terraform init

# バックエンド設定を指定して初期化
terraform init -backend-config="bucket=my-terraform-state"

# 実行計画の確認
terraform plan

# 実行計画をファイルに保存
terraform plan -out=tfplan

# 特定のリソースのみ計画
terraform plan -target=aws_instance.example
```

### 1.2. 適用と破棄

```sh
# 変更の適用
terraform apply

# 保存した計画を適用
terraform apply tfplan

# 自動承認で適用（CI/CD向け）
terraform apply -auto-approve

# リソースの破棄
terraform destroy

# 特定のリソースのみ破棄
terraform destroy -target=aws_instance.example
```

### 1.3. 状態管理

```sh
# 状態の確認
terraform state list

# リソースの詳細確認
terraform state show aws_instance.example

# リソースの移動（リファクタリング時）
terraform state mv aws_instance.old aws_instance.new

# 既存リソースのインポート
terraform import aws_instance.example i-1234567890abcdef0

# 状態からリソースを削除（実リソースは残す）
terraform state rm aws_instance.example
```

### 1.4. その他の便利なコマンド

```sh
# 設定の検証
terraform validate

# フォーマット
terraform fmt

# 再帰的にフォーマット
terraform fmt -recursive

# 出力値の確認
terraform output

# JSON形式で出力
terraform output -json

# 対話的なコンソール（式のテスト用）
terraform console

# プロバイダーのロック
terraform providers lock -platform=linux_amd64 -platform=darwin_amd64
```

## 2. リソース管理

### 2.1. リソースブロックの基本構造

```hcl
resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  tags = {
    Name = "example-instance"
  }
}
```

### 2.2. メタ引数

- `depends_on`: 明示的な依存関係
- `count`: リソースの複製（インデックスベース）
- `for_each`: リソースの複製（キーベース）
- `provider`: 代替プロバイダーの指定
- `lifecycle`: ライフサイクル制御

### 2.3. ライフサイクル設定

```hcl
resource "aws_instance" "example" {
  # ...

  lifecycle {
    create_before_destroy = true  # 置換時に新規作成を先に
    prevent_destroy       = true  # 削除防止
    ignore_changes        = [tags] # 変更を無視する属性
    replace_triggered_by  = [null_resource.trigger.id]
  }
}
```

## 3. モジュール設計

### 3.1. モジュールの呼び出し

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "my-vpc"
  cidr = "10.0.0.0/16"
}
```

### 3.2. モジュールソースの種類

- ローカルパス: `./modules/vpc`
- Terraform Registry: `hashicorp/consul/aws`
- GitHub: `github.com/hashicorp/example`
- S3: `s3::https://s3-eu-west-1.amazonaws.com/bucket/module.zip`

### 3.3. モジュールのベストプラクティス

- 標準的なファイル構成: `main.tf`, `variables.tf`, `outputs.tf`
- README.md でドキュメント化
- 意味のあるデフォルト値を設定
- バリデーションで入力を検証

## 4. 状態管理

### 4.1. リモートバックエンドの設定

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

### 4.2. 状態管理のベストプラクティス

- リモートバックエンドを使用（チーム開発必須）
- 状態ロックを有効化（同時実行防止）
- 暗号化を有効化
- 状態ファイルを直接編集しない（`terraform state` コマンドを使用）
- 環境ごとに状態ファイルを分離

## 5. 変数と出力

### 5.1. 入力変数

```hcl
variable "instance_type" {
  type        = string
  description = "EC2 インスタンスタイプ"
  default     = "t2.micro"

  validation {
    condition     = contains(["t2.micro", "t2.small", "t2.medium"], var.instance_type)
    error_message = "許可されたインスタンスタイプを指定してください"
  }
}
```

### 5.2. 変数の設定方法（優先順位順）

1. コマンドライン `-var`, `-var-file`
2. `*.auto.tfvars` ファイル
3. `terraform.tfvars.json`
4. `terraform.tfvars`
5. 環境変数 `TF_VAR_*`
6. デフォルト値

### 5.3. 機密データの取り扱い

```hcl
variable "db_password" {
  type      = string
  sensitive = true  # 出力でマスク
}

output "connection_string" {
  value     = "postgres://user:${var.db_password}@host/db"
  sensitive = true  # 機密データを含む出力
}
```

**注意**: 状態ファイルには機密データがプレーンテキストで保存される。リモートバックエンドの暗号化や HCP Terraform の使用を推奨。

## 6. プロバイダー

### 6.1. プロバイダーの宣言

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

### 6.2. 複数プロバイダーの使用

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

## 7. 組み込み関数

### 7.1. よく使う関数

```hcl
# 文字列操作
join("-", ["foo", "bar"])          # "foo-bar"
split(",", "a,b,c")                # ["a", "b", "c"]
format("Hello, %s!", "World")      # "Hello, World!"

# コレクション操作
length(["a", "b", "c"])            # 3
lookup(map, key, default)          # マップから値を取得
merge(map1, map2)                  # マップのマージ
flatten([["a"], ["b", "c"]])       # ["a", "b", "c"]

# 型変換
tostring(123)                      # "123"
tolist(set)                        # セットをリストに
tomap(object)                      # オブジェクトをマップに

# 条件式
coalesce("", "default")            # "default"（最初の非空値）
try(expression, fallback)          # エラー時にフォールバック
```

## 8. HCP Terraform / Terraform Cloud

### 8.1. 主な機能

- リモート状態管理（暗号化、バージョニング）
- チームコラボレーション
- ポリシー適用（Sentinel）
- プライベートモジュールレジストリ
- VCS 連携（GitHub, GitLab など）
- コスト見積もり

### 8.2. ワークスペース設定

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

## 9. セキュリティベストプラクティス

### 9.1. 認証情報の管理

- ハードコードしない
- 環境変数または認証ファイルを使用
- IAM ロール / サービスアカウントを推奨
- HashiCorp Vault との連携

### 9.2. 状態ファイルのセキュリティ

- 暗号化されたバックエンドを使用
- アクセス制御を適切に設定
- `.terraform/` を `.gitignore` に追加
- `*.tfvars` を `.gitignore` に追加（機密情報含む場合）

## 10. 詳細ドキュメント

`docs/` ディレクトリに以下の詳細ドキュメントが含まれている

- `language-overview.md` - Terraform 言語の概要
- `resources.md` - リソース管理の詳細
- `modules.md` - モジュール設計
- `state.md` - 状態管理
- `providers.md` - プロバイダー設定
- `variables.md` - 変数と出力
- `expressions.md` - 式と関数
- `lifecycle.md` - ライフサイクル制御
- `backends.md` - バックエンド設定
- `sensitive-data.md` - 機密データの取り扱い
- `data-sources.md` - データソース
- `hcp-terraform.md` - HCP Terraform / Terraform Cloud

## 11. 参考リンク

- 公式ドキュメント: https://developer.hashicorp.com/terraform/docs
- 言語リファレンス: https://developer.hashicorp.com/terraform/language
- CLI リファレンス: https://developer.hashicorp.com/terraform/cli
- プロバイダーレジストリ: https://registry.terraform.io/
- モジュールレジストリ: https://registry.terraform.io/browse/modules
- HCP Terraform: https://developer.hashicorp.com/terraform/cloud-docs
