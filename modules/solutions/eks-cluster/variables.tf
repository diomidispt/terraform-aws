variable "env_name" {
  description = "The name of the environment (e.g. project name)."
  type        = string
}

variable "env_type" {
  description = "The environment type (e.g. dev, staging, prod)."
  type        = string
}

variable "vpc_name" {
  description = "The Name of the VPC to deploy the solution in"
  type        = string
}

variable "iam_admins" {
  description = "A list of IAM roles ARNs who can administrate this stack"
  type        = list(string)
}

variable "cluster_system_admins" {
  description = "A list of IAM roles ARNs who will be mapped to the system:masters Kubernetes RBAC group and be provided with admin access to the cluster"
  type        = list(string)
}

variable "cluster_system_viewers" {
  description = "A list of IAM roles ARNs who be provided with view access to the cluster"
  type        = list(string)
}

variable "additional_access_entries" {
  description = "Additional access entries for the aws-auth configmap"
  type = list(
    object(
      {
        role_arn   = string
        username   = optional(string)
        type       = string
        groups     = optional(list(string))
        depends_on = optional(list(string))
      }
    )
  )
  default = []
}

variable "authentication_mode" {
  description = "The authentication mode for the EKS cluster. Valid values are: 'API', 'CONFIG_MAP', 'API_AND_CONFIG_MAP'. Default is 'API'"
  type        = string
  default     = "API"
  validation {
    condition     = contains(["API", "CONFIG_MAP", "API_AND_CONFIG_MAP"], var.authentication_mode)
    error_message = "Invalid authentication mode. Valid values are: 'API', 'CONFIG_MAP', 'API_AND_CONFIG_MAP'."
  }

}

variable "kubernetes_version" {
  description = "The Kubernetes version for the EKS cluster"
  type        = string
}

variable "deletion_protection" {
  description = "If true, the cluster cannot be deleted. Default is false"
  type        = bool
}

variable "cluster_additional_permissions" {
  description = "Additional IAM permissions for the EKS cluster role"
  type = list(
    object(
      {
        Version = string,
        Statement = list(
          object(
            {
              Effect   = string,
              Action   = list(string),
              Resource = string
            }
          )
        )
      }
    )
  )
}

variable "kubernetes_cidr" {
  description = "The CIDR block for the Kubernetes service IPs. Default is 10.100.0.0/16"
  type        = string
}

# With validation
variable "cluster_upgrade_support_type" {
  description = "The support type for EKS cluster version upgrades. Valid values are: 'STANDARD', 'EXTENDED'"
  type        = string
  validation {
    condition     = contains(["STANDARD", "EXTENDED"], var.cluster_upgrade_support_type)
    error_message = "Invalid cluster upgrade support type. Valid values are: 'STANDARD', 'EXTENDED'."
  }
}

variable "node_group_instance_type" {
  description = "A list of instance types for the EKS node group"
  type        = string
}

variable "managed_node_groups" {
  description = "The scaling configuration for the EKS managed node groups"
  type = map(
    object(
      {
        scaling_config = object(
          {
            desired_size = number
            max_size     = number
            min_size     = number
          }
        )
        update_config = object(
          {
            max_unavailable = number
          }
        )
        # "ON_DEMAND" (default) or "SPOT". Spot is ~70% cheaper but AWS can
        # reclaim the node with a 2-minute warning — fine for dev/learning.
        capacity_type = optional(string, "ON_DEMAND")
      }
    )
  )
}

# Dynamic security group rules for EKS node group
variable "node_sg_rules" {
  description = "List of security group rules for EKS node group"
  type = list(
    object(
      {
        type                     = string
        from_port                = number
        to_port                  = number
        protocol                 = string
        cidr_blocks              = optional(list(string))
        source_security_group_id = optional(string)
        self                     = optional(bool)
        description              = optional(string)
      }
    )
  )
}

variable "eks_addons_list" {
  description = "List of eks addons to install"
  type = list(
    object(
      {
        name    = string
        version = string
      }
    )
  )
  default = []
}

variable "additional_security_group_ids" {
  description = "List of additional security group IDs to attach to the EKS cluster"
  type        = list(string)
  default     = []

}

variable "ami_type" {
  description = "The AMI type for the EKS node group. Use 'CUSTOM' for custom AMI via launch template, or AWS-supported types."
  type        = string
}