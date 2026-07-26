data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = ["${var.env_name}-${var.env_type}-VPC"]
  }
}
