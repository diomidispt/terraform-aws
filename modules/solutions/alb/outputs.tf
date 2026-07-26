output "dns_name" {
  description = "The DNS name of the ALB — use this to access the app"
  value       = aws_lb.this.dns_name
}

output "arn" {
  description = "The ARN of the ALB"
  value       = aws_lb.this.arn
}

output "zone_id" {
  description = "The hosted zone ID of the ALB — for Route53 alias records"
  value       = aws_lb.this.zone_id
}

output "target_group_arn" {
  description = "The ARN of the target group — passed to ECS service"
  value       = aws_lb_target_group.this.arn
}
