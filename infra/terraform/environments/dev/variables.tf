variable "environment" {
  description = "Environment (dev/prod)"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID for your domain"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository URL for IAM permissions"
  type        = string
  default     = "https://github.com/mrmeddah/pipelock-starter" 
}

/*variable "dockerhub_username" {
  description = "Docker Hub account username"
  type        = string
}

variable "dockerhub_password" {
  description = "Docker Hub account password"
  type        = string
  sensitive   = true
}

*/
