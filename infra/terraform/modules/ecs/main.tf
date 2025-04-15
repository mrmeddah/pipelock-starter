resource "aws_ecs_cluster" "metabase" {
  name = "metabase-${var.environment}"
}

data "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = var.db_secret_arn
}

resource "aws_ecs_task_definition" "metabase" {
  family                   = "metabase-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn
  container_definitions = jsonencode([
    {
      name        = "metabase"
      image       = var.metabase_image
      essential   = true
      portMappings = [{
        containerPort = 3000
        hostPort      = 3000
        protocol      = "tcp"
      }]
      environment = [
        { name = "MB_DB_TYPE", value = "postgres" },
        { name = "MB_DB_DBNAME", value = "metabase" },
        { name = "MB_DB_PORT", value = "5432" },
        { name = "MB_DB_HOST", value = var.db_host }
      ]
      secrets = [
        {
          name      = "MB_DB_USER"
          valueFrom = "${var.db_secret_arn}:username::"
        },
        {
          name      = "MB_DB_PASS"
          valueFrom = "${var.db_secret_arn}:password::"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.metabase.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "metabase"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "metabase" {
  name            = "metabase"
  cluster         = aws_ecs_cluster.metabase.id
  task_definition = aws_ecs_task_definition.metabase.arn
  desired_count   = var.desired_count
  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_groups
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = "metabase"
    container_port   = 3000
  }
  dynamic "capacity_provider_strategy" {
    for_each = var.capacity_provider_strategy
    content {
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight            = capacity_provider_strategy.value.weight
    }
  }
  lifecycle {
    ignore_changes = [desired_count]
  }
}

/* resource "aws_security_group" "ecs" {
  name        = "metabase-ecs-${var.environment}"
  description = "Allow inbound from ALB only"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [module.metabase_alb.aws_security_group.alb.id]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
} */

resource "aws_cloudwatch_log_group" "metabase" {
  name              = "/ecs/metabase-${var.environment}"
  retention_in_days = 30
}
