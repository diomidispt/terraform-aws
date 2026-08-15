terraform {
  backend "s3" {
    region         = "us-east-1"
    bucket         = "sauron-cicd-tfstate"
    key            = "sauron-eks/DioProjects-us-east-1-sauron-eks-DEV/terraform.tfstate"
    dynamodb_table = "sauron-cicd-tfstate"
    encrypt        = "true"
  }
}
