variable "env_name" {
  description = "The name for this environment (e.g., sauron)"
  type        = string
}

variable "env_type" {
  description = "The type of this environment (e.g., DEV, PROD)"
  type        = string
}

variable "subnet_ids" {
  description = "List of private subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs to attach to the RDS instance"
  type        = list(string)
}

variable "db" {
  description = "RDS instance configuration"
  type = object({
    engine                  = string
    engine_version          = string
    instance_class          = string
    name                    = string
    username                = string
    password                = string
    allocated_storage       = optional(number, 20)
    backup_retention_period = optional(number, 7)
    skip_final_snapshot     = optional(bool, true)
    deletion_protection     = optional(bool, false)
  })
}
