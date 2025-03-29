resource "aws_ecs_cluster" "metabase" {
  name = "metabase-${var.environment}"
}

resource "aws_ecs_task_definition" "metabase" {
  family                   = "metabase"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024  # 1 vCPU
  memory                   = 2048  # 2 GB RAM
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn

  container_definitions = jsonencode([{
    name  = "metabase"
    image = var.metabase_image
    portMappings = [{
      containerPort = 3000
      hostPort      = 3000
    }]
    environment = [
      { name = "MB_DB_TYPE", value = "postgres" },
      { name = "MB_DB_HOST", value = var.db_host },
      { name = "MB_DB_PORT", value = "5432" }
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
      logDriver = "awslogs",
      options = {
        "awslogs-group"         = "/ecs/metabase-${var.environment}",
        "awslogs-region"        = var.aws_region,
        "awslogs-stream-prefix" = "metabase"
      }
    }
  }])
}

resource "aws_ecs_service" "metabase" {
  name            = "metabase"
  cluster         = aws_ecs_cluster.metabase.id
  task_definition = aws_ecs_task_definition.metabase.arn
  desired_count   = var.environment == "prod" ? 2 : 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false  # Private subnets only
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = "metabase"
    container_port   = 3000
  }

  lifecycle {
    ignore_changes = [desired_count]  # Allow auto-scaling
  }
}

resource "aws_security_group" "ecs" {
  name        = "metabase-ecs-${var.environment}"
  description = "Allow inbound from ALB only"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_cloudwatch_log_group" "metabase" {
  name              = "/ecs/metabase-${var.environment}"
  retention_in_days = 30
}