output "rds_endpoint" {
  description = "RDS endpoint for Metabase connection"
  value       = aws_db_instance.metabase.endpoint
}

output "db_secret_arn" {
  description = "ARN of the DB credentials secret"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

 output "db_subnet_cidr_blocks" {
  value = [for s in aws_db_subnet_group.metabase.subnet_ids : data.aws_subnet.selected[s].cidr_block]
}

data "aws_subnet" "selected" {
  for_each = toset(aws_db_subnet_group.metabase.subnet_ids)
  id       = each.key
}
