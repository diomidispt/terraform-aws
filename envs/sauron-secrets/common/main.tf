module "secret_manager" {
  source  = "../../../modules/resources/secrets"
  secrets = local.secrets.data
}

