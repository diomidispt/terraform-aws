resource "aws_kms_key" "this" {
  count       = length(var.keys)
  description = var.keys[count.index].description
  policy = jsonencode(
    {
      Version = var.keys[count.index].policy.Version
      Statement = [
        for stmt in var.keys[count.index].policy.Statement : merge(
          {
            Effect = stmt.Effect
            Action = stmt.Action
          },
          stmt.Principal != null ? { Principal = stmt.Principal } : {},
          stmt.Resource != null ? { Resource = stmt.Resource } : {},
          stmt.Condition != null ? { Condition = stmt.Condition } : {}
        )
      ]
    }
  )
}

resource "aws_kms_alias" "this" {
  count         = length(var.keys)
  name          = "alias/${var.keys[count.index].alias}"
  target_key_id = aws_kms_key.this[count.index].key_id
}