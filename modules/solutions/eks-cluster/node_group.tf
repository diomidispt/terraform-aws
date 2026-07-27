resource "aws_eks_node_group" "this" {
  for_each        = var.managed_node_groups
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${local.cluster_name}-node-group-${each.key}"
  node_role_arn   = aws_iam_role.eks_node_group.arn
  subnet_ids      = local.private_subnet_ids

  scaling_config {
    desired_size = each.value.scaling_config.desired_size
    max_size     = each.value.scaling_config.max_size
    min_size     = each.value.scaling_config.min_size
  }
  update_config {
    max_unavailable = each.value.update_config.max_unavailable
  }

  launch_template {
    id      = aws_launch_template.eks_node_group.id
    version = aws_launch_template.eks_node_group.latest_version
  }

  labels = {
    "workload" = each.key
  }

  ami_type = var.ami_type

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role.eks_node_group,
    aws_iam_role_policy_attachment.eks_node_group_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_node_group_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks_node_group_AmazonEC2ContainerRegistryReadOnly,
  ]
}