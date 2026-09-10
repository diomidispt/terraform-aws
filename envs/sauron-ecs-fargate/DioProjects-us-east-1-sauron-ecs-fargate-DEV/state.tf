terraform {
  backend "s3" {
    region         = "us-east-1"
    bucket         = "sauron-cicd-tfstate"
    key            = "sauron-ecs-fargate/DioProjects-us-east-1-sauron-ecs-fargate-DEV/terraform.tfstate"
    dynamodb_table = "sauron-cicd-tfstate"
    use_lockfile   = true
    encrypt        = "true"
  }
}
