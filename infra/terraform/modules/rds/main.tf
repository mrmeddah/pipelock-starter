resource "aws_db_instance" "metabase" {
  identifier             = "metabase-${var.environment}"
  engine                 = "postgres"
  engine_version         = "12.20"  
  instance_class         = var.instance_class
  allocated_storage      = 20
  storage_type           = "gp3"
  storage_encrypted      = true
  username               = jsondecode(aws_secretsmanager_secret_version.db_credentials.secret_string)["username"]
  password               = jsondecode(aws_secretsmanager_secret_version.db_credentials.secret_string)["password"]
  db_subnet_group_name   = aws_db_subnet_group.metabase.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.metabase.name
  skip_final_snapshot    = var.environment == "dev" ? true : false
  multi_az               = var.environment == "prod" ? true : false #Function checks if multi-az is true or false | ya3ni enabled wela la
  backup_retention_period = 7
  publicly_accessible    = false
  deletion_protection    = var.environment == "prod" ? true : false

  tags = {
    Environment = var.environment
  }
}

resource "aws_db_subnet_group" "metabase" {
  name       = "metabase-${var.environment}"
  subnet_ids = var.subnet_ids
}

resource "aws_db_parameter_group" "metabase" {
  name   = "metabase-postgres12"
  family = "postgres12" 

  parameter {
    name  = "rds.force_ssl"
    value = "1"  
  }

  parameter {
    name  = "log_statement"
    value = "all" 
  }
}


resource "aws_security_group" "rds" {
  name        = "metabase-rds-${var.environment}"
  description = "Allow inbound from ECS only"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.ecs_security_group_id]
  }
}

resource "aws_secretsmanager_secret" "db_credentials" {
  name = "metabase-db-credentials-${var.environment}"
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = "metabase_admin"
    password = random_password.db_password.result
  })
}

resource "random_password" "db_password" {
  length  = 16
  special = false
}