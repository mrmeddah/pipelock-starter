output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.metabase.dns_name
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.metabase.arn
}

output "alb_security_group_id" {
  description = "Security group ID of the ALB"
  value       = aws_security_group.alb.id
}