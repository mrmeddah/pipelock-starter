output "rds_endpoint" {
  description = "RDS endpoint for Metabase connection"
  value       = aws_db_instance.metabase.endpoint
}

output "db_secret_arn" {
  description = "ARN of the DB credentials secret"
  value       = aws_secretsmanager_secret.db_credentials.arn
}