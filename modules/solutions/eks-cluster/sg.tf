resource "aws_security_group" "eks_node_group" {
  name        = "${local.cluster_name}-node-group-sg"
  description = "Security group for EKS node group of the cluster ${local.cluster_name}"
  vpc_id      = local.vpc_id

  tags = {
    "name"                                        = "${local.cluster_name}-node-group-sg"
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
    "karpenter.sh/discovery"                      = local.cluster_name
  }
}

resource "aws_security_group_rule" "cluster_to_node_group" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_node_group.id
  description              = "Allow cluster control plane to communicate with nodes - Managed by Terraform"
  source_security_group_id = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

resource "aws_security_group_rule" "node_group_rules" {
  for_each = { for idx, rule in var.node_sg_rules : idx => rule }

  type                     = each.value.type
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  security_group_id        = aws_security_group.eks_node_group.id
  cidr_blocks              = lookup(each.value, "cidr_blocks", null)
  source_security_group_id = lookup(each.value, "source_security_group_id", null)
  self                     = lookup(each.value, "self", null)
  description              = lookup(each.value, "description", null)
}

resource "aws_security_group_rule" "eks_cluster_from_node_group" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
  source_security_group_id = aws_security_group.eks_node_group.id
  description              = "Allow all traffic from the EKS node group security group"
}