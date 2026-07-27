module "kms" {
  source = "../../resources/kms"
  keys = [
    {
      description = "KMS key for EKS Secret encryption"
      alias       = "eks-secrets-key-${var.env_type}"
      policy = {
        Version = "2012-10-17",
        Statement = [
          {
            Effect = "Allow",
            Principal = {
              AWS = concat(var.iam_admins, [aws_iam_role.cluster.arn])
            },
            Action   = ["kms:*"],
            Resource = "*"
          }
        ]
      }
    }
  ]

}