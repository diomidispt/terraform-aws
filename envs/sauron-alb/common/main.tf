module "this" {
  source             = "../../../modules/solutions/alb"
  env_name           = var.env_name
  env_type           = var.env_type
  security_group_ids = [var.alb_sg_id]
  target_port        = var.target_port
  health_check_path  = var.health_check_path
}
