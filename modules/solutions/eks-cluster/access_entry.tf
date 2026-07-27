resource "aws_eks_access_entry" "system_masters" {
  for_each      = toset(var.cluster_system_admins)
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = each.value
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "eks_admin" {
  for_each      = toset(var.cluster_system_admins)
  cluster_name  = aws_eks_cluster.this.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
  principal_arn = each.value

  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_access_policy_association" "eks_cluster_admin" {
  for_each      = toset(var.cluster_system_admins)
  cluster_name  = aws_eks_cluster.this.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = each.value

  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_access_entry" "system_viewers" {
  for_each      = toset(var.cluster_system_viewers)
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = each.value
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "eks_view_only" {
  for_each      = toset(var.cluster_system_viewers)
  cluster_name  = aws_eks_cluster.this.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
  principal_arn = each.value

  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_access_entry" "additional" {
  for_each          = { for idx, entry in var.additional_access_entries : idx => entry }
  cluster_name      = aws_eks_cluster.this.name
  principal_arn     = each.value.role_arn
  type              = each.value.type
  kubernetes_groups = each.value.groups
  user_name         = each.value.username
}