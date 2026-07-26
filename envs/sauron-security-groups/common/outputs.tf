# Re-export the module's security group IDs so `terraform output` (and CI) can
# surface them for the alb/rds/ecs tfvars in later waves.
output "alb_sg_id" {
  value = module.this.alb_sg_id
}

output "ecs_sg_id" {
  value = module.this.ecs_sg_id
}

output "rds_sg_id" {
  value = module.this.rds_sg_id
}
