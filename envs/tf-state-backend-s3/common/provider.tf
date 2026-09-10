terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.7.0"
    }
  }
}

provider "aws" {
  region              = var.region.id
  allowed_account_ids = [var.account.id]
  default_tags {
    tags = {
      "tf:managed-by" : "terraform",
      "owner" : "DevOps",
      "environment" : var.environment_name,
      "purpose" : "terraform-state-storage",
    }
  }
}