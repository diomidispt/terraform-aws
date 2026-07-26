# Surfaced for the wave-3 ecs handoff and for reaching the app.
output "dns_name" {
  value = module.this.dns_name
}

output "target_group_arn" {
  value = module.this.target_group_arn
}
