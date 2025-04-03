# Core VPC with NAT Gateway (required)
module "metabase_vpc" {
  source          = "../../modules/vpc"
  environment     = "dev"
  vpc_cidr        = "10.0.0.0/16"                   
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]  
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
  enable_nat_gateway = true                         
  single_nat_gateway = true                         
}

# IAM (Least privileges)
module "metabase_iam" {
  source       = "../../modules/iam"
  github_repo  = "https://github.com/mrmeddah/pipelock-starter"             
  enable_s3_exports = false                      
}

# RDS (Single-AZ to save costs, but easily upgradable f prod) ghire l testing
module "metabase_rds" {
  source          = "../../modules/rds"
  environment     = "dev"
  vpc_id          = module.metabase_vpc.vpc_id
  subnet_ids      = module.metabase_vpc.private_subnet_ids
  ecs_security_group_id = module.metabase_ecs.ecs_security_group_id
  instance_class  = "db.t4g.micro"                 
  multi_az        = false                         
  skip_final_snapshot = true                      
}

module "metabase_alb" {
  source           = "../../modules/alb"
  environment      = "dev"
  vpc_id           = module.metabase_vpc.vpc_id
  public_subnet_ids = module.metabase_vpc.public_subnet_ids
  domain_name      = "metabase.pipelock.dev"
  route53_zone_id  = data.aws_route53_zone.primary.zone_id  
}

# ECS (Fargate with Spot for cost savings)
module "metabase_ecs" {
  source                      = "../../modules/ecs"
  environment                 = "dev"
  vpc_id                      = module.metabase_vpc.vpc_id
  subnet_ids                  = module.metabase_vpc.private_subnet_ids
  ecs_task_execution_role_arn = module.metabase_iam.ecs_task_execution_role_arn
  ecs_task_role_arn           = module.metabase_iam.ecs_task_role_arn
  db_host                     = module.metabase_rds.rds_endpoint
  db_secret_arn               = module.metabase_rds.db_secret_arn
  alb_target_group_arn        = module.metabase_alb.target_group_arn
  alb_security_group_id       = module.metabase_alb.alb_security_group_id
  aws_region                  = "us-east-1"
  metabase_image              = "metabase/metabase:latest"
  desired_count               = 1                   
  capacity_provider_strategy = [                   
    {
      capacity_provider = "FARGATE_SPOT",
      weight           = 1
    }
  ]
}

# VPC Endpoints (Reduce NAT traffic costs)
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = module.metabase_vpc.vpc_id
  service_name      = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = "Gateway"                   # Free
  route_table_ids   = module.metabase_vpc.private_route_table_ids
}

resource "aws_vpc_endpoint" "ecr" {
  vpc_id              = module.metabase_vpc.vpc_id
  service_name        = "com.amazonaws.us-east-1.ecr.dkr"
  vpc_endpoint_type   = "Interface"               
  subnet_ids          = module.metabase_vpc.private_subnet_ids
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true
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

resource "aws_acm_certificate" "metabase" {
  domain_name       = "metabase.pipelock.dev"
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = tolist(aws_acm_certificate.metabase.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.metabase.domain_validation_options)[0].resource_record_type
  records = [tolist(aws_acm_certificate.metabase.domain_validation_options)[0].resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "metabase" {
  certificate_arn         = aws_acm_certificate.metabase.arn
  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
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
    module.metabase_alb,
    aws_acm_certificate_validation.metabase
  ]
}