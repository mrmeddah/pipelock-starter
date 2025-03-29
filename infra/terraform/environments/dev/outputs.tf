output "metabase_url" {
  description = "Metabase ALB DNS URL"
  value       = "https://${module.metabase_alb.alb_dns_name}"
}

output "rds_endpoint" {
  description = "RDS endpoint (for debugging)"
  value       = module.metabase_rds.rds_endpoint
}