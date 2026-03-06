# AWS CLI Rules

## 1. Basic Rules

- NEVER: Do not use resource-modifying commands
- YOU MUST: Specify profile with `--profile xxx` or `AWS_PROFILE=xxx aws ...`

## 2. Allowed Commands (Read-only)

```sh
aws s3 ls --profile xxx
aws ec2 describe-instances --profile xxx
aws iam list-users --profile xxx
```

## 3. Prohibited Commands (Resource Modification)

```sh
aws s3 rm ...
aws ec2 terminate-instances ...
aws iam create-user ...
```
