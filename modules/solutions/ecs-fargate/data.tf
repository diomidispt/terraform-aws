data "aws_region" "current" {}

# Look up the VPC's private subnets by tag (same convention as the ALB/RDS modules),
# so the env doesn't have to pass subnet IDs explicitly.
data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = ["${var.env_name}-${var.env_type}-VPC"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }
  filter {
    name   = "tag:Name"
    values = ["${var.env_name}-${var.env_type}-Subnet-Private-*"]
  }
}
