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

variable "alb_sg_id" {
  description = "ALB security group ID — from sauron-security-groups env output"
  type        = string
}

variable "target_port" {
  description = "Port the application listens on"
  type        = number
  default     = 8080
}

variable "health_check_path" {
  description = "Path used by ALB to health check the application"
  type        = string
  default     = "/health"
}
