resource "aws_security_group" "alb" {
  name        = "${var.env_name}-${var.env_type}-ALB-SG"
  description = "ALB security group - allows HTTP from internet"
  vpc_id      = data.aws_vpc.this.id
}

resource "aws_security_group" "ecs" {
  name        = "${var.env_name}-${var.env_type}-ECS-SG"
  description = "ECS tasks security group"
  vpc_id      = data.aws_vpc.this.id
}

resource "aws_security_group" "rds" {
  name        = "${var.env_name}-${var.env_type}-RDS-SG"
  description = "RDS security group - accepts only from ECS"
  vpc_id      = data.aws_vpc.this.id
}

resource "aws_security_group_rule" "alb_ingress_http" {
  type              = "ingress"
  security_group_id = aws_security_group.alb.id
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "HTTP from internet"
}

resource "aws_security_group_rule" "alb_egress_ecs" {
  type                     = "egress"
  security_group_id        = aws_security_group.alb.id
  from_port                = var.app_port
  to_port                  = var.app_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs.id
  description              = "Outbound to ECS tasks"
}

resource "aws_security_group_rule" "ecs_ingress_alb" {
  type                     = "ingress"
  security_group_id        = aws_security_group.ecs.id
  from_port                = var.app_port
  to_port                  = var.app_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  description              = "Inbound from ALB"
}

resource "aws_security_group_rule" "ecs_egress_rds" {
  type                     = "egress"
  security_group_id        = aws_security_group.ecs.id
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.rds.id
  description              = "Outbound to RDS"
}

resource "aws_security_group_rule" "ecs_egress_internet" {
  type              = "egress"
  security_group_id = aws_security_group.ecs.id
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "HTTPS outbound for ECR image pull via NAT"
}

resource "aws_security_group_rule" "rds_ingress_ecs" {
  type                     = "ingress"
  security_group_id        = aws_security_group.rds.id
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs.id
  description              = "Inbound from ECS tasks"
}
