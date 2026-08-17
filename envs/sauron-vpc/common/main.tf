module "this" {
  source   = "../../../modules/solutions/vpc"
  env_name = var.env_name
  env_type = var.env_type
  vpc      = var.vpc
  tags     = var.tags
}
