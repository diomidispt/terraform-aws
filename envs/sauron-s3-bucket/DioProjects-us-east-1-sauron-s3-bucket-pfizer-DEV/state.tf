terraform {
  backend "s3" {
    region         = "us-east-1"
    bucket         = "sauron-cicd-tfstate"
    key            = "sauron-s3-bucket/DioProjects-us-east-1-sauron-s3-bucket-pfizer-DEV/terraform.tfstate"
    dynamodb_table = "sauron-cicd-tfstate"
    use_lockfile   = true
    encrypt        = "true"
  }
}
