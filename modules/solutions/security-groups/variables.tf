variable "env_name" {
  description = "The name for this environment (e.g., sauron)"
  type        = string
}

variable "env_type" {
  description = "The type of this environment (e.g., DEV, PROD)"
  type        = string
}

variable "app_port" {
  description = "Port the application listens on"
  type        = number
  default     = 8080
}
