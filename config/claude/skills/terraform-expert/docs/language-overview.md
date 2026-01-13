---
source_url: https://developer.hashicorp.com/terraform/language
fetched_at: 2025-12-16
---

# Terraform Configuration Language Overview

## Purpose and Core Function

Terraform's configuration language serves as the primary interface for managing infrastructure. The language enables users to declare resources representing infrastructure objects, with all other features designed to support resource definition flexibility and convenience.

## Basic Syntax Components

The Terraform language consists of three fundamental elements:

**Blocks**: "containers for other content and usually represent the configuration of some kind of object, like a resource." Blocks contain a type, optional labels, and a body with arguments and nested blocks.

**Arguments**: These assign values to names within blocks.

**Expressions**: These represent values through literals or by combining and referencing other values.

## Key Characteristics

The language operates declaratively, focusing on desired outcomes rather than procedural steps. "The ordering of blocks and the files they are organized into are generally not significant; Terraform only considers implicit and explicit relationships between resources."

## Configuration Structure

A Terraform configuration can span multiple files and directories. Common building blocks include:

- Resource declarations
- Variables for parameterization
- Provider configurations
- Data sources for querying infrastructure

This declarative approach allows Terraform to determine proper execution order based on resource dependencies rather than explicit sequencing, simplifying infrastructure management at scale.

## ファイル構成のベストプラクティス

```
project/
├── main.tf           # メインのリソース定義
├── variables.tf      # 入力変数の宣言
├── outputs.tf        # 出力値の定義
├── providers.tf      # プロバイダー設定
├── terraform.tfvars  # 変数値（機密情報は含めない）
├── versions.tf       # Terraform とプロバイダーのバージョン制約
└── modules/          # ローカルモジュール
    └── vpc/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```
