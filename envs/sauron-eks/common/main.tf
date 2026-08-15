module "this" {
  source = "../../../modules/solutions/eks-cluster"

  env_name = var.env_name
  env_type = var.env_type
  vpc_name = var.vpc_name

  kubernetes_version           = var.kubernetes_version
  kubernetes_cidr              = var.kubernetes_cidr
  cluster_upgrade_support_type = var.cluster_upgrade_support_type
  deletion_protection          = var.deletion_protection

  # access (kubectl / KMS key policy)
  iam_admins                     = var.iam_admins
  cluster_system_admins          = var.cluster_system_admins
  cluster_system_viewers         = var.cluster_system_viewers
  cluster_additional_permissions = var.cluster_additional_permissions

  # node group
  node_group_instance_type = var.node_group_instance_type
  ami_type                 = var.ami_type
  managed_node_groups      = var.managed_node_groups
  node_sg_rules            = var.node_sg_rules
}
