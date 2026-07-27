variable "secrets" {
  description = "List of secrets to create. Each secret is an object with name, description, secret_string (map), and optional kms (object)."
  type = list(
    object(
      {
        name          = string
        description   = string
        secret_string = map(string)
        kms = optional(
          object(
            {
              description = string
              alias       = optional(string)
              policy = optional(
                object(
                  {
                    Version = string
                    Statement = list(
                      object(
                        {
                          Effect = string
                          Principal = object(
                            {
                              AWS = list(string)
                            }
                          )
                          Action   = list(string)
                          Resource = string
                        }
                      )
                    )
                  }
                )
              )
              # Add more KMS params as needed
            }
          )
        )
      }
    )
  )
}
