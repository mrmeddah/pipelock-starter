variable "environment" {
  description = "Environment (dev/prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where RDS will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet IDs for RDS"
  type        = list(string)
}

/*variable "ecs_security_group_id" {
  description = "Security group ID of ECS tasks"
  type        = string
}*/

variable "private_subnets_cidr_blocks" {
  description = "CIDR blocks of private subnets for RDS access"
  type        = list(string)
}

variable "instance_class" {
  description = "RDS instance type"
  type        = string
  default     = "db.t4g.micro"  
}

variable "multi_az" {
  description = "Enable multi-AZ deployment for high availability"
  type        = bool
  default     = false  
}

variable "skip_final_snapshot" {
  description = "Skip creating a final snapshot when destroying RDS"
  type        = bool
  default     = true  
}