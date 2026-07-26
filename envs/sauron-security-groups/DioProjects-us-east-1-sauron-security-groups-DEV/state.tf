terraform {
  backend "s3" {
    region         = "us-east-1"
    bucket         = "sauron-cicd-tfstate"
    key            = "sauron-security-groups/DioProjects-us-east-1-sauron-security-groups-DEV/terraform.tfstate"
    dynamodb_table = "sauron-cicd-tfstate"
    encrypt        = "true"
  }
}
