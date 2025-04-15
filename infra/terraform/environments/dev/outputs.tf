output "metabase_url" {
  description = "Metabase ALB DNS URL"
  value       = "https://${module.metabase_alb.alb_dns_name}"
}

output "rds_endpoint" {
  description = "RDS endpoint (for debugging)"
  value       = module.metabase_rds.rds_endpoint
}

/* output "dockerhub_secret_arn" {
  description = "ARN of Docker Hub credentials secret"
  value       = module.metabase_iam.dockerhub_secret_arn
} 

*/

output "ecr_repository_url" {
  value = module.metabase_ecr.ecr_repository_url
}

output "ecs_security_group_id" {
  value = aws_security_group.ecs.id
}