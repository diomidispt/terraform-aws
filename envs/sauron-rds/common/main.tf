module "this" {
  source             = "../../../modules/solutions/rds"
  env_name           = var.env_name
  env_type           = var.env_type
  security_group_ids = [var.rds_sg_id]
  db                 = var.db
}
