output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.metabase.arn
}

output "alb_security_group_id" {
  description = "Security group ID of the ALB"
  value       = aws_security_group.alb.id
}
output "alb_dns_name" {
  value = aws_lb.this.dns_name
}

output "alb_zone_id" {
  value = aws_lb.this.zone_id
}

output "certificate_arn" {
  value = aws_acm_certificate.metabase.arn
}