terraform {
  backend "s3" {
    region         = "us-east-1"
    bucket         = "sauron-cicd-tfstate"
    key            = "vpc/DioProjects-us-east-1-vpc-test-DEV/terraform.tfstate"
    dynamodb_table = "sauron-cicd-tfstate"
    encrypt        = "true"
  }
}
