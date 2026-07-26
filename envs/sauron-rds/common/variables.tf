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

variable "rds_sg_id" {
  description = "RDS security group ID — from sauron-security-groups env output"
  type        = string
}

variable "db" {
  description = "RDS instance configuration (no password here)"
  type = object({
    engine                  = string
    engine_version          = string
    instance_class          = string
    name                    = string
    username                = string
    allocated_storage       = optional(number, 20)
    backup_retention_period = optional(number, 7)
    skip_final_snapshot     = optional(bool, true)
    deletion_protection     = optional(bool, false)
  })
}
