output "rds_endpoint" {
  description = "RDS endpoint for Metabase connection"
  value       = aws_db_instance.metabase.endpoint
}

output "db_secret_arn" {
  description = "ARN of the DB credentials secret"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "db_subnet_cidr_blocks" {
  value = var.private_subnets_cidr_blocks
}


output "rds_security_group_id" {
  value = aws_security_group.rds.id
}
