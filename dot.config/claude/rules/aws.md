# AWS CLI ルール

## 基本ルール

- NEVER: リソース変更系コマンドは使用しない
- YOU MUST: `--profile xxx` もしくは `AWS_PROFILE=xxx aws ...` の形でプロファイルを指定する

## 許可されるコマンド (読み取り専用)

```sh
aws s3 ls --profile xxx
aws ec2 describe-instances --profile xxx
aws iam list-users --profile xxx
```

## 禁止されるコマンド (リソース変更)

```sh
aws s3 rm ...
aws ec2 terminate-instances ...
aws iam create-user ...
```
