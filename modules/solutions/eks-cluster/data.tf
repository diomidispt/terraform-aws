data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }

  filter {
    name = "tag:Name"
    values = [
      "*-Subnet-Private-*",
    ]
  }
}

data "tls_certificate" "this" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}