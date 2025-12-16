---
source_url: https://developer.hashicorp.com/terraform/language/functions
fetched_at: 2025-12-16
---

# Terraform Built-in Functions Overview

## Function Categories

Terraform provides organized collections of built-in functions across multiple categories:

## Numeric Functions

- `abs(number)` - 絶対値
- `ceil(number)` - 切り上げ
- `floor(number)` - 切り捨て
- `log(number, base)` - 対数
- `max(numbers...)` - 最大値
- `min(numbers...)` - 最小値
- `parseint(string, base)` - 文字列を整数に変換
- `pow(number, power)` - べき乗
- `signum(number)` - 符号

## String Functions

- `chomp(string)` - 末尾の改行を削除
- `endswith(string, suffix)` - 接尾辞チェック
- `format(format, args...)` - フォーマット文字列
- `formatlist(format, list)` - リスト要素のフォーマット
- `indent(spaces, string)` - インデント追加
- `join(separator, list)` - リストを結合
- `lower(string)` - 小文字変換
- `regex(pattern, string)` - 正規表現マッチ
- `replace(string, search, replace)` - 文字列置換
- `split(separator, string)` - 文字列を分割
- `startswith(string, prefix)` - 接頭辞チェック
- `strcontains(string, substr)` - 部分文字列チェック
- `substr(string, offset, length)` - 部分文字列取得
- `title(string)` - タイトルケース変換
- `trim(string, chars)` - 指定文字を削除
- `trimprefix(string, prefix)` - 接頭辞を削除
- `trimsuffix(string, suffix)` - 接尾辞を削除
- `trimspace(string)` - 空白を削除
- `upper(string)` - 大文字変換

## Collection Functions

- `alltrue(list)` - すべて true か
- `anytrue(list)` - いずれかが true か
- `chunklist(list, size)` - リストを分割
- `coalesce(values...)` - 最初の非 null 値
- `compact(list)` - 空文字列を除去
- `concat(lists...)` - リストを連結
- `contains(list, value)` - 要素の存在チェック
- `distinct(list)` - 重複を除去
- `element(list, index)` - インデックスで取得
- `flatten(list)` - ネストを平坦化
- `index(list, value)` - 要素のインデックス
- `keys(map)` - マップのキー一覧
- `length(collection)` - 要素数
- `lookup(map, key, default)` - マップから値を取得
- `merge(maps...)` - マップをマージ
- `one(list)` - 単一要素を取得
- `range(max)` - 数値リストを生成
- `reverse(list)` - リストを逆順に
- `setintersection(sets...)` - 積集合
- `setproduct(sets...)` - 直積
- `setsubtract(set1, set2)` - 差集合
- `setunion(sets...)` - 和集合
- `slice(list, start, end)` - スライス
- `sort(list)` - ソート
- `sum(list)` - 合計
- `transpose(map)` - 転置
- `values(map)` - マップの値一覧
- `zipmap(keys, values)` - キーと値からマップを作成

## Encoding Functions

- `base64decode(string)` - Base64 デコード
- `base64encode(string)` - Base64 エンコード
- `csvdecode(string)` - CSV をパース
- `jsondecode(string)` - JSON をパース
- `jsonencode(value)` - JSON にエンコード
- `urlencode(string)` - URL エンコード
- `yamldecode(string)` - YAML をパース
- `yamlencode(value)` - YAML にエンコード

## Filesystem Functions

- `abspath(path)` - 絶対パスに変換
- `dirname(path)` - ディレクトリ名を取得
- `pathexpand(path)` - ~ を展開
- `basename(path)` - ファイル名を取得
- `file(path)` - ファイル内容を読み込み
- `fileexists(path)` - ファイル存在チェック
- `fileset(path, pattern)` - パターンマッチするファイル
- `templatefile(path, vars)` - テンプレートを処理

## Type Conversion Functions

- `tostring(value)` - 文字列に変換
- `tonumber(value)` - 数値に変換
- `tobool(value)` - 真偽値に変換
- `tolist(value)` - リストに変換
- `toset(value)` - セットに変換
- `tomap(value)` - マップに変換

## 便利な関数の使用例

```hcl
# 条件付きのデフォルト値
locals {
  instance_type = coalesce(var.instance_type, "t2.micro")
}

# リストのフィルタリング
locals {
  production_instances = [
    for instance in var.instances : instance
    if instance.environment == "production"
  ]
}

# マップのマージ
locals {
  all_tags = merge(
    var.default_tags,
    var.additional_tags,
    {
      ManagedBy = "terraform"
    }
  )
}

# JSON の生成
resource "aws_iam_policy" "example" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = ["arn:aws:s3:::my-bucket/*"]
      }
    ]
  })
}
```

## Testing Functions

Users can experiment with functions using the `terraform console` command to verify behavior before implementation.

```sh
$ terraform console
> join("-", ["foo", "bar", "baz"])
"foo-bar-baz"
> lookup({a = "1", b = "2"}, "a", "default")
"1"
> cidrsubnet("10.0.0.0/16", 8, 1)
"10.0.1.0/24"
```
