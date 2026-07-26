data "aws_subnets" "private" {
  filter {
    name   = "tag:Name"
    values = ["${var.env_name}-${var.env_type}-Subnet-Private-*"]
  }
}
