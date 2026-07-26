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

variable "ecs_sg_id" {
  description = "ECS security group ID — from sauron-security-groups env output"
  type        = string
}

variable "target_group_arn" {
  description = "ALB target group ARN — from sauron-alb env output"
  type        = string
}

variable "ecr_image" {
  description = "Full ECR image URI including tag"
  type        = string
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 8080
}

variable "environment_variables" {
  description = "Plain environment variables injected into the container"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "secrets" {
  description = "Secrets Manager values injected as environment variables"
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

variable "secret_arns" {
  description = "Secrets Manager ARNs the execution role can read"
  type        = list(string)
  default     = []
}
