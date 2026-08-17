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

variable "vpc" {
  description = "VPC configuration"
  type = object({
    cidr_block = string
  })
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(any)
  default     = {}
}
