resource "aws_launch_template" "eks_node_group" {
  name                   = "${local.cluster_name}-node-group-lt"
  instance_type          = var.node_group_instance_type
  vpc_security_group_ids = concat([aws_security_group.eks_node_group.id], var.additional_security_group_ids)
}