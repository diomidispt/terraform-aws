terraform {
  backend "s3" {
    region         = "us-east-1"
    bucket         = "sauron-cicd-tfstate"
    key            = "sauron-secrets/DioProjects-us-east-1-sauron-secrets-DEV/terraform.tfstate"
    dynamodb_table = "sauron-cicd-tfstate"
    encrypt        = "true"
  }
}
