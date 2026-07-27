resource "aws_eks_addon" "pod_identity" {
  count         = length(var.eks_addons_list)
  cluster_name  = aws_eks_cluster.this.name
  addon_name    = var.eks_addons_list[count.index].name
  addon_version = var.eks_addons_list[count.index].version
}