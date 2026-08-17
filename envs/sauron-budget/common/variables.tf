variable "account" {
  description = "An object containing info for the target AWS account"
  type = object({
    id    = string
    name  = string
    alias = string
  })
}

variable "region" {
  description = "An object containing info for the target AWS region"
  type = object({
    id   = string
    name = string
  })
}

variable "budgets" {
  description = "A list of budget configurations"
  type = list(
    object(
      {
        name         = string
        budget_type  = optional(string, "COST")
        limit_amount = string
        limit_unit   = optional(string, "USD")
        time_unit    = optional(string, "MONTHLY")
        notifications = list(
          object(
            {
              comparison_operator        = string
              threshold                  = number
              threshold_type             = string
              notification_type          = string
              subscriber_email_addresses = optional(list(string), [])
              subscriber_sns_topic_arns  = optional(list(string), [])
            }
          )
        )
      }
    )
  )
}
