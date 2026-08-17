module "this" {
  source  = "../../../modules/resources/budget"
  budgets = var.budgets
}
