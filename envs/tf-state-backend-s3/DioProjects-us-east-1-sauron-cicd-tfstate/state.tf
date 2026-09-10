terraform {
  backend "s3" {
    region         = "us-east-1"
    bucket         = "sauron-cicd-tfstate"
    key            = "tf-state-backend-s3/DioProjects-us-east-1-sauron-cicd-tfstate/terraform.tfstate"
    dynamodb_table = "sauron-cicd-tfstate"
    encrypt        = "true"
  }
}
