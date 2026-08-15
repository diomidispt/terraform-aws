variable "account" {
  description = "An object containing info for the target AWS account"
  type = object({
    id    = string
    name  = string
    alias = string
  })
}

variable "region" {
  description = "An object containing info for the target AWS region"
  type = object({
    id   = string
    name = string
  })
}

variable "env_name" {
  description = "The name for this environment (e.g., sauron)"
  type        = string
}

variable "env_type" {
  description = "The type of this environment (e.g., DEV, PROD)"
  type        = string
}

variable "vpc_name" {
  description = "Name (tag:Name) of the VPC to deploy into"
  type        = string
}

variable "kubernetes_version" {
  description = "EKS control-plane version"
  type        = string
}

variable "kubernetes_cidr" {
  description = "Service IPv4 CIDR (must not overlap the VPC CIDR)"
  type        = string
}

variable "cluster_upgrade_support_type" {
  description = "STANDARD or EXTENDED"
  type        = string
}

variable "deletion_protection" {
  description = "Protect the cluster from deletion"
  type        = bool
}

variable "iam_admins" {
  description = "IAM role ARNs that can administrate this stack (incl. the KMS key)"
  type        = list(string)
}

variable "cluster_system_admins" {
  description = "IAM role ARNs granted cluster-admin (kubectl) via access entries"
  type        = list(string)
}

variable "cluster_system_viewers" {
  description = "IAM role ARNs granted view access via access entries"
  type        = list(string)
}

variable "cluster_additional_permissions" {
  description = "Extra inline IAM permissions for the cluster role (usually empty)"
  type = list(object({
    Version = string
    Statement = list(object({
      Effect   = string
      Action   = list(string)
      Resource = string
    }))
  }))
}

variable "node_group_instance_type" {
  description = "EC2 instance type for the node group"
  type        = string
}

variable "ami_type" {
  description = "AMI type for the node group"
  type        = string
}

variable "managed_node_groups" {
  description = "Managed node groups + scaling/update config"
  type = map(object({
    scaling_config = object({
      desired_size = number
      max_size     = number
      min_size     = number
    })
    update_config = object({
      max_unavailable = number
    })
  }))
}

variable "node_sg_rules" {
  description = "Security-group rules for the node group"
  type = list(object({
    type                     = string
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string))
    source_security_group_id = optional(string)
    self                     = optional(bool)
    description              = optional(string)
  }))
}
