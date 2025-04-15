variable "environment" {
  description = "Environment (dev/prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet IDs for ECS"
  type        = list(string)
}

variable "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  type        = string
}

variable "ecs_task_role_arn" {
  description = "ARN of the ECS task role"
  type        = string
}

variable "db_host" {
  description = "RDS endpoint"
  type        = string
}

variable "db_secret_arn" {
  description = "ARN of the DB credentials secret"
  type        = string
}

variable "alb_target_group_arn" {
  description = "ARN of the ALB target group"
  type        = string
}

variable "alb_security_group_id" {
  description = "Security group ID of the ALB"
  type        = string
}

variable "metabase_image" {
  description = "Metabase ECR image URI"
  type        = string
  default     = "361769579987.dkr.ecr.us-east-1.amazonaws.com/metabase"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}


variable "desired_count" {
  description = "Number of ECS tasks to run"
  type        = number
  default     = 1
}

variable "capacity_provider_strategy" {
  description = "Capacity provider strategy for ECS service"
  type = list(object({
    capacity_provider = string
    weight           = number
  }))
  default = []
}

/*variable "rds_endpoint" {  
  description = "RDS endpoint for Metabase connection"  
  type        = string  
}*/  


variable "security_groups" {
  description = "Security group IDs for ECS tasks"
  type        = list(string)
}

/*variable "dockerhub_secret_arn" {
  description = "ARN of the Docker Hub credentials secret"
  type        = string
}

*/
