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
  description = "Metabase Docker image URI"
  type        = string
  default     = "metabase/metabase:latest"
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
  description = "ECS capacity provider strategy (Spot/On-Demand)"
  type = list(object({
    capacity_provider = string
    weight           = number
  }))
  default = [{
    capacity_provider = "FARGATE_SPOT",
    weight           = 1
  }]
}

variable "rds_endpoint" {  
  description = "RDS endpoint for Metabase connection"  
  type        = string  
}  


variable "security_groups" {
  description = "Security group IDs for ECS tasks"
  type        = list(string)
}
