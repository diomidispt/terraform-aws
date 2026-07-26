variable "env_name" {
  description = "The name for this environment (e.g., sauron)"
  type        = string
}

variable "env_type" {
  description = "The type of this environment (e.g., DEV, PROD)"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID to deploy the ALB in"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs to attach to the ALB"
  type        = list(string)
}

variable "target_port" {
  description = "The port the application listens on"
  type        = number
  default     = 8080
}

variable "health_check_path" {
  description = "The path the ALB uses to health check the application"
  type        = string
  default     = "/health"
}
