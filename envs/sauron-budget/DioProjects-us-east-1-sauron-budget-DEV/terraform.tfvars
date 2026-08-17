# Monthly account cost budget for the sauron DEV account.
# Emails diomidispt@gmail.com once actual spend exceeds $5 for the month.
budgets = [
  {
    name         = "sauron-monthly-budget"
    limit_amount = "5"
    time_unit    = "MONTHLY"
    notifications = [
      {
        comparison_operator        = "GREATER_THAN"
        threshold                  = 100
        threshold_type             = "PERCENTAGE"
        notification_type          = "ACTUAL"
        subscriber_email_addresses = ["diomidispt@gmail.com"]
      }
    ]
  }
]
