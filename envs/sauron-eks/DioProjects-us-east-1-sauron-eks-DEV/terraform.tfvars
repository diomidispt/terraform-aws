env_name = "sauron"
env_type = "DEV"
vpc_name = "sauron-DEV-VPC"

kubernetes_version           = "1.31"
kubernetes_cidr              = "172.20.0.0/16" # service CIDR; does not overlap VPC 10.0.0.0/20
cluster_upgrade_support_type = "STANDARD"      # avoids EXTENDED-support surcharges
deletion_protection          = false

# IAM access — SSO admin = you (kubectl), CI role = pipeline. Viewers: none.
iam_admins = [
  "arn:aws:iam::298104300097:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AdministratorAccess_c6b5653e23fb902b",
  "arn:aws:iam::298104300097:role/github-actions-ci",
]
cluster_system_admins = [
  "arn:aws:iam::298104300097:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AdministratorAccess_c6b5653e23fb902b",
  "arn:aws:iam::298104300097:role/github-actions-ci",
]
cluster_system_viewers         = []
cluster_additional_permissions = []

# Cheapest sensible node group: a single small on-demand node.
# Bump instance_type to t3.medium (or min_size 2) before adding the monitoring stack.
node_group_instance_type = "t3.small"
ami_type                 = "AL2023_x86_64_STANDARD"

managed_node_groups = {
  default = {
    scaling_config = { desired_size = 1, max_size = 2, min_size = 1 }
    update_config  = { max_unavailable = 1 }
    # SPOT: ~70% cheaper (t3.small ~$5/mo vs ~$15). AWS can reclaim with a
    # 2-min warning; the managed node group drains + launches a replacement.
    # Fine for a single-node learning cluster. Flip to "ON_DEMAND" if you
    # ever run something you need to stay up.
    capacity_type = "SPOT"
  }
}

node_sg_rules = [
  {
    type        = "egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All egress (ECR pulls, RDS, internet via NAT)"
  }
]
