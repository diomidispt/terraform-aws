resource "aws_kms_key" "this" {
  for_each    = { for s in var.secrets : s.name => s if s.kms != null }
  description = each.value.kms.description
  policy      = each.value.kms.policy != null ? jsonencode(each.value.kms.policy) : null
}
resource "aws_kms_alias" "this" {
  for_each      = { for s in var.secrets : s.name => s if s.kms != null }
  name          = "alias/${each.value.kms.alias != null ? each.value.kms.alias : each.value.name}"
  target_key_id = aws_kms_key.this[each.value.name].key_id
}

resource "aws_secretsmanager_secret" "this" {
  for_each    = { for s in var.secrets : s.name => s }
  name        = each.value.name
  description = each.value.description
  kms_key_id  = each.value.kms != null ? aws_kms_key.this[each.value.name].arn : null
}

resource "aws_secretsmanager_secret_version" "this" {
  for_each      = { for s in var.secrets : s.name => s }
  secret_id     = aws_secretsmanager_secret.this[each.value.name].id
  secret_string = jsonencode(each.value.secret_string)
}
