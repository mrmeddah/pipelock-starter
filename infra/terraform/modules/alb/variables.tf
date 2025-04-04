variable "environment" {
  description = "Environment (dev/prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for ALB"
  type        = list(string)
}

variable "domain_name" {
  description = "Domain name for HTTPS certificate pipelock.dev"
  type        = string
}

variable "route53_zone_id" {
  description = "Route53 Hosted Zone ID for DNS validation"
  type        = string
}

variable "private_subnets_cidr_blocks" {
  description = "CIDR blocks of private subnets for ECS security group egress"
  type        = list(string)
}