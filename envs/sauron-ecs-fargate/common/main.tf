module "this" {
  source                = "../../../modules/solutions/ecs-fargate"
  env_name              = var.env_name
  env_type              = var.env_type
  security_group_ids    = [var.ecs_sg_id]
  target_group_arn      = var.target_group_arn
  ecr_image             = var.ecr_image
  container_port        = var.container_port
  environment_variables = var.environment_variables
  secrets               = var.secrets
  secret_arns           = var.secret_arns
}
