resource "aws_budgets_budget" "this" {
  count        = length(var.budgets)
  name         = var.budgets[count.index].name
  budget_type  = var.budgets[count.index].budget_type
  limit_amount = var.budgets[count.index].limit_amount
  limit_unit   = var.budgets[count.index].limit_unit
  time_unit    = var.budgets[count.index].time_unit

  dynamic "notification" {
    for_each = var.budgets[count.index].notifications
    content {
      comparison_operator        = notification.value.comparison_operator
      threshold                  = notification.value.threshold
      threshold_type             = notification.value.threshold_type
      notification_type          = notification.value.notification_type
      subscriber_email_addresses = notification.value.subscriber_email_addresses
      subscriber_sns_topic_arns  = notification.value.subscriber_sns_topic_arns
    }
  }
}
