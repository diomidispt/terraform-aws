# Monthly account cost budgets for the sauron DEV account.
# Two tiers, both emailing diomidispt@gmail.com on ACTUAL spend: $5 is the
# "something is running that shouldn't be" tripwire, $30 the hard ceiling.
# AWS bills $0.02/budget/day past the first two, so keep this list at two.
# The module keys budgets by count - append new ones, never insert.
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
  },
  {
    name         = "sauron-monthly-budget-30"
    limit_amount = "30"
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
