resource "aws_iam_role" "cluster" {
  name = "${local.cluster_name}-eks-cluster-role"
  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "sts:AssumeRole",
            "sts:TagSession"
          ]
          Effect = "Allow"
          Principal = {
            Service = "eks.amazonaws.com"
          }
        },
      ]
    }
  )
}

resource "aws_iam_role_policy" "cluster_additional_permissions" {
  count  = length(var.cluster_additional_permissions)
  role   = aws_iam_role.cluster.id
  policy = jsonencode(var.cluster_additional_permissions)
}

resource "aws_iam_role_policy_attachment" "cluster_additional" {
  count      = length(var.cluster_additional_permissions)
  policy_arn = aws_iam_role_policy.cluster_additional_permissions[0].id
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name

}

# EKS Node Group Role and Attachments
resource "aws_iam_role" "eks_node_group" {
  name = "${local.cluster_name}-node-group-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks_node_group_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group.name
}

resource "aws_iam_role_policy_attachment" "eks_node_group_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group.name
}

resource "aws_iam_role_policy_attachment" "eks_node_group_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group.name
}

resource "aws_iam_openid_connect_provider" "this" {
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = local.thumbprint_list
}