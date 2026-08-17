allowed_repos = [
  "diomidispt/terraform-aws:*",
  "diomidispt/go-app:*"
]

name = "github-actions-ci"

iam_policy = {
  Version = "2012-10-17"
  Statement = [
    {
      Action = [
        "lambda:*",
        "s3:*",
        "s3-object-lambda:*",
        "cloudformation:*",
        "cloudfront:*",
        "ecr:*",
        "elasticloadbalancing:*",
        "scheduler:*",
        "elasticfilesystem:*",
        "secretsmanager:*",
        "acm:*",
        "budgets:*",
        "docdb:*",
        "dynamodb:*",
        "ec2:*",
        "eks:*",
        "route53:*",
        "logs:*",
        "codeartifact:*",
        "rds:*",
        "sqs:*",
        "sns:*",
        "ssm:*",
        "kms:*",
        "ecs:*",
        "synthetics:*",
        "ses:*",
        "events:*",
        "airflow:*",
        "cognito-idp:*",
        "access-analyzer:*"
      ]
      Effect   = "Allow"
      Resource = "*"
    },
    {
      # TODO: Capture needed IAM and apply least privilege
      Action = [
        "iam:*"
      ]
      Effect   = "Allow"
      Resource = "*"
    },
    {
      Effect   = "Allow"
      Action   = ["sts:GetServiceBearerToken"]
      Resource = "*"
    }
  ]
}