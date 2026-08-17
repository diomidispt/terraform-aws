output "budget_names" {
  description = "List of Budget names created"
  value       = [for b in aws_budgets_budget.this : b.name]
}

output "budget_ids" {
  description = "List of Budget IDs created"
  value       = [for b in aws_budgets_budget.this : b.id]
}
