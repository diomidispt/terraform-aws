locals {
  cluster_name       = "${var.env_name}-${var.env_type}-eks-cluster"
  vpc_id             = data.aws_vpc.selected.id
  private_subnet_ids = data.aws_subnets.private.ids
  thumbprint_list = [
    data.tls_certificate.this.certificates[0].sha1_fingerprint
  ]
}