output "kms_keys_arns" {
  description = "List of KMS Key ARNs created"
  value       = [for k in aws_kms_key.this : k.arn]
}

output "kms_keys_ids" {
  description = "List of KMS Key IDs created"
  value       = [for k in aws_kms_key.this : k.id]
}