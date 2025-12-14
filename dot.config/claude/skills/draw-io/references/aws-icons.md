# AWS アイコンとサービス名

## 1. 正しいサービス名の規則

| 接頭辞 | 例 |
|--------|-----|
| Amazon | Amazon ECS, Amazon ECR, Amazon S3, Amazon RDS, Amazon CloudWatch |
| AWS | AWS Lambda, AWS IAM, AWS CloudFormation, AWS Step Functions |

- 略称のみの使用は避ける (ECS → Amazon ECS)
- 正式名称を使用する

## 2. アイコンスタイル

```xml
shape=mxgraph.aws4.resourceIcon;resIcon=mxgraph.aws4.{service_name};
```

- `mxgraph.aws4.*` を使用 (aws3 は古い)

## 3. カテゴリ別アイコン

### 3.1. Compute (コンピューティング)

| サービス | resIcon |
|----------|---------|
| Amazon EC2 | mxgraph.aws4.ec2 |
| AWS Lambda | mxgraph.aws4.lambda |
| Amazon ECS | mxgraph.aws4.ecs |
| Amazon EKS | mxgraph.aws4.eks |
| AWS Fargate | mxgraph.aws4.fargate |

### 3.2. Storage & Database (ストレージ・DB)

| サービス | resIcon |
|----------|---------|
| Amazon S3 | mxgraph.aws4.s3 |
| Amazon RDS | mxgraph.aws4.rds |
| Amazon DynamoDB | mxgraph.aws4.dynamodb |
| Amazon ElastiCache | mxgraph.aws4.elasticache |
| Amazon EFS | mxgraph.aws4.efs |

### 3.3. Networking (ネットワーク)

| サービス | resIcon |
|----------|---------|
| Amazon VPC | mxgraph.aws4.vpc |
| Amazon CloudFront | mxgraph.aws4.cloudfront |
| Amazon Route 53 | mxgraph.aws4.route_53 |
| Elastic Load Balancing | mxgraph.aws4.elb |
| Amazon API Gateway | mxgraph.aws4.api_gateway |

### 3.4. Analytics & ML (分析・機械学習)

| サービス | resIcon |
|----------|---------|
| Amazon Athena | mxgraph.aws4.athena |
| Amazon Redshift | mxgraph.aws4.redshift |
| AWS Glue | mxgraph.aws4.glue |
| Amazon SageMaker | mxgraph.aws4.sagemaker |
| Amazon Kinesis | mxgraph.aws4.kinesis |

### 3.5. Management & Monitoring (管理・監視)

| サービス | resIcon |
|----------|---------|
| Amazon CloudWatch | mxgraph.aws4.cloudwatch |
| AWS CloudFormation | mxgraph.aws4.cloudformation |
| AWS IAM | mxgraph.aws4.iam |
| AWS Systems Manager | mxgraph.aws4.systems_manager |
| AWS CloudTrail | mxgraph.aws4.cloudtrail |

### 3.6. Integration (統合)

| サービス | resIcon |
|----------|---------|
| Amazon SNS | mxgraph.aws4.sns |
| Amazon SQS | mxgraph.aws4.sqs |
| Amazon EventBridge | mxgraph.aws4.eventbridge |
| AWS Step Functions | mxgraph.aws4.step_functions |

### 3.7. Container & Registry

| サービス | resIcon |
|----------|---------|
| Amazon ECR | mxgraph.aws4.ecr |
| Amazon ECS | mxgraph.aws4.ecs |
| Amazon EKS | mxgraph.aws4.eks |

## 4. グループアイコン

```xml
<!-- AWS Cloud -->
shape=mxgraph.aws4.group;grIcon=mxgraph.aws4.group_aws_cloud;

<!-- VPC -->
shape=mxgraph.aws4.group;grIcon=mxgraph.aws4.group_vpc;

<!-- Availability Zone -->
shape=mxgraph.aws4.group;grIcon=mxgraph.aws4.group_availability_zone;

<!-- Public/Private Subnet -->
shape=mxgraph.aws4.group;grIcon=mxgraph.aws4.group_security_group;
```

## 5. アイコン検索スクリプト

[scripts/find_aws_icon.py](../scripts/find_aws_icon.py) を使用して効率的に検索可能。
