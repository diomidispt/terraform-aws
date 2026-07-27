# Customer-managed KMS keys for the sauron DEV account.
# The policy grants full key admin to your SSO admin role + the CI role.
# The sops key encrypts/decrypts the secrets.enc.json used by sauron-secrets.
keys = [
  {
    description = "KMS key for SOPS-encrypted secrets (sauron DEV)"
    alias       = "sauron-dev-sops-key"
    policy = {
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Principal = {
            AWS = [
              "arn:aws:iam::298104300097:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AdministratorAccess_c6b5653e23fb902b",
              "arn:aws:iam::298104300097:role/github-actions-ci",
            ]
          }
          Action   = ["kms:*"]
          Resource = "*"
        }
      ]
    }
  }
]
