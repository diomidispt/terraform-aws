# Surfaced for the wave-3 ecs handoff (DB_HOST + the Secrets Manager ARN).
output "address" {
  value = module.this.address
}

output "endpoint" {
  value = module.this.endpoint
}

output "master_user_secret_arn" {
  value = module.this.master_user_secret_arn
}
