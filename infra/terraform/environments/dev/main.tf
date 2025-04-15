module "metabase_ecr" {
  source                      = "../../modules/ecr"
  ecs_task_execution_role_arn = module.metabase_iam.ecs_task_execution_role_arn
}

# Core VPC with NAT Gateway (required)
module "metabase_vpc" {
  source          = "../../modules/vpc"
  environment = var.environment
  vpc_cidr        = "10.0.0.0/16"
  rds_subnet_cidr_blocks = module.metabase_rds.db_subnet_cidr_blocks                    
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]  
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
  enable_nat_gateway = true                         
  single_nat_gateway = true                       
}

# RDS (Single-AZ to save costs, but easily upgradable f prod) ghire l testing
module "metabase_rds" {
  source          = "../../modules/rds"
  environment     = "dev"
vpc_id      = module.metabase_vpc.vpc_id
subnet_ids  = module.metabase_vpc.private_subnet_ids
  private_subnets_cidr_blocks = module.metabase_vpc.private_subnets_cidr_blocks
  instance_class  = "db.t4g.micro"                 
  multi_az        = false                         
  skip_final_snapshot = true                      
}

# IAM (Least privileges)
module "metabase_iam" {
  source            = "../../modules/iam"
  db_secret_arn = module.metabase_rds.db_secret_arn
  environment   = "dev"
  github_repo       = "mrmeddah/pipelock-starter"
  enable_s3_exports = false
  depends_on = [module.metabase_rds]
}


# Deja endi certifs ISSUED, O mbghitch L hardcoding dyal ARN

data "aws_acm_certificate" "metabase" {
  domain      = "metabase.pipelock.dev"
  statuses    = ["ISSUED"]
  most_recent = true  
}

data "aws_acm_certificate" "wildcard" {
  domain      = "pipelock.dev"
  statuses    = ["ISSUED"]
  most_recent = true
  types       = ["AMAZON_ISSUED"] 
}

module "metabase_alb" {
  source           = "../../modules/alb"
  environment      = "dev"
  vpc_id           = module.metabase_vpc.vpc_id
  public_subnet_ids = module.metabase_vpc.public_subnet_ids
  private_subnets_cidr_blocks = module.metabase_vpc.private_subnets_cidr_blocks
  domain_name      = "metabase.pipelock.dev"
  route53_zone_id  = data.aws_route53_zone.primary.zone_id 
  certificate_arn = data.aws_acm_certificate.metabase.arn
}

# ECS (Fargate with Spot for cost savings)
resource "aws_security_group" "ecs" {
  name        = "metabase-ecs-${var.environment}"
  description = "Allow inbound from ALB + outbound to RDS and VPC endpoints"
  vpc_id      = module.metabase_vpc.vpc_id

/*  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [module.metabase_alb.alb_security_group_id]
  }

  egress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [module.metabase_vpc.vpc_endpoints_security_group_id]
    description     = "Allow ECR/VPC endpoint access"
  }

  egress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [module.metabase_rds.rds_security_group_id]
    description     = "Allow RDS access"
  }*/
}

resource "aws_security_group_rule" "ecs_to_rds" {
  type                     = "egress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs.id
  source_security_group_id = module.metabase_rds.rds_security_group_id
  description              = "Allow ECS to RDS"
}

resource "aws_security_group_rule" "rds_from_ecs" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = module.metabase_rds.rds_security_group_id
  source_security_group_id = aws_security_group.ecs.id
  description              = "Allow RDS to accept traffic from ECS"
}

resource "aws_security_group_rule" "alb_to_ecs" {
  type                     = "ingress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs.id
  source_security_group_id = module.metabase_alb.alb_security_group_id
  description              = "Allow ALB to ECS"
}

/*module "metabase_ecs" {
  source                      = "../../modules/ecs"
  environment                 = "dev"
    rds_endpoint         = module.metabase_rds.rds_endpoint
  vpc_id      = module.metabase_vpc.vpc_id
  subnet_ids           = module.metabase_vpc.private_subnet_ids
security_groups    = [aws_security_group.ecs.id]
  ecs_task_execution_role_arn = module.metabase_iam.ecs_task_execution_role_arn
  ecs_task_role_arn           = module.metabase_iam.ecs_task_role_arn
  db_host                     = module.metabase_rds.rds_endpoint
  db_secret_arn               = module.metabase_rds.db_secret_arn
  alb_target_group_arn        = module.metabase_alb.target_group_arn
  alb_security_group_id       = module.metabase_alb.alb_security_group_id
  aws_region                  = "us-east-1"
  metabase_image = "${module.metabase_ecr.ecr_repository_url}:latest"
  desired_count               = 1  
  depends_on = [module.metabase_rds]                 
capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE_SPOT",
      weight           = 1
    }
  ]
}*/

module "metabase_ecs" {
  source                      = "../../modules/ecs"
  environment                 = "dev"
  vpc_id                      = module.metabase_vpc.vpc_id
  subnet_ids                  = module.metabase_vpc.private_subnet_ids
  security_groups             = [aws_security_group.ecs.id]
  ecs_task_execution_role_arn = module.metabase_iam.ecs_task_execution_role_arn
  ecs_task_role_arn           = module.metabase_iam.ecs_task_role_arn
  db_host                     = module.metabase_rds.rds_endpoint
  db_secret_arn               = module.metabase_rds.db_secret_arn
  alb_target_group_arn        = module.metabase_alb.target_group_arn
  alb_security_group_id       = module.metabase_alb.alb_security_group_id
  aws_region                  = "us-east-1"
  metabase_image              = "${module.metabase_ecr.ecr_repository_url}:latest"
  desired_count               = 1
  capacity_provider_strategy   = [
    {
      capacity_provider = "FARGATE_SPOT"
      weight            = 1
    }
  ]
  depends_on = [
    module.metabase_rds,
    module.metabase_ecr
  ]
}

resource "aws_security_group_rule" "ecs_to_vpc_endpoints" {
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs.id
  source_security_group_id = module.metabase_vpc.vpc_endpoints_security_group_id
  description              = "Allow ECS to VPC endpoints"
}

resource "aws_security_group_rule" "vpc_endpoints_from_ecs" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = module.metabase_vpc.vpc_endpoints_security_group_id
  source_security_group_id = aws_security_group.ecs.id
  description              = "Allow VPC endpoints to accept traffic from ECS"
}

resource "aws_security_group" "vpc_endpoints" {
  name        = "metabase-vpc-endpoints"
  vpc_id      = module.metabase_vpc.vpc_id
  description = "Allow HTTPS to VPC endpoints"
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [module.metabase_vpc.vpc_cidr_block]
  }
}

# Route 53 A3chiri 
# (I've already bought the domain via Porkbun not AWS, 
# so I changed the block from resource to data and added an end point to the domain name)
data "aws_route53_zone" "primary" {
  name = "pipelock.dev." #No9ta 
  private_zone = false #7ite deja created a hosted zone, o f output it shows that it's privatezone is false 
}

resource "aws_route53_record" "metabase" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "metabase.pipelock.dev"
  type    = "A"

  alias {
    name                   = module.metabase_alb.alb_dns_name
    zone_id                = module.metabase_alb.alb_zone_id
    evaluate_target_health = true
  }

  depends_on = [
    module.metabase_alb
  ]
}

#Test instance


