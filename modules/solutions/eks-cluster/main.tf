resource "aws_eks_cluster" "this" {
  name = local.cluster_name

  role_arn = aws_iam_role.cluster.arn
  version  = var.kubernetes_version

  vpc_config {
    endpoint_private_access = var.env_name == "prod" ? true : false
    endpoint_public_access  = var.env_name != "prod" ? true : false
    public_access_cidrs     = ["0.0.0.0/0"]
    subnet_ids              = local.private_subnet_ids
    security_group_ids      = concat([aws_security_group.eks_node_group.id], var.additional_security_group_ids)
  }

  access_config {
    authentication_mode                         = var.authentication_mode
    bootstrap_cluster_creator_admin_permissions = false
  }

  deletion_protection = var.deletion_protection

  encryption_config {
    provider {
      key_arn = module.kms.kms_keys_arns[0]
    }
    resources = ["secrets"]
  }

  kubernetes_network_config {
    service_ipv4_cidr = var.kubernetes_cidr
  }

  upgrade_policy {
    support_type = var.cluster_upgrade_support_type
  }

  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role.cluster,
  ]
}

# TODO: Determine is this is needed
# resource "aws_ec2_tag" "default_cluster_sg_tag" {
#   resource_id = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
#   key         = "karpenter.sh/discovery"
#   value       = local.cluster_name
# }