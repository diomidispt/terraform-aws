variable "keys" {
  description = "A list of KMS key configurations"
  type = list(
    object(
      {
        description = string
        alias       = string
        policy = object(
          {
            Version = string,
            Statement = list(
              object(
                {
                  Effect    = string,
                  Principal = optional(map(list(string))),
                  Action    = list(string),
                  Resource  = string
                  Condition = optional(map(map(list(string))))
                }
              )
            )
          }
        )
      }
    )
  )
}
