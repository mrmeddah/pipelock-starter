resource "aws_ecr_repository" "metabase" {
  name                 = "metabase"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Name = "metabase"
  }
}

resource "aws_ecr_lifecycle_policy" "metabase" {
  repository = aws_ecr_repository.metabase.name
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 30 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 30
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "aws_ecr_repository_policy" "metabase" {
  repository = aws_ecr_repository.metabase.name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowECSTaskExecutionRole",
        Effect    = "Allow",
        Principal = {
          AWS = var.ecs_task_execution_role_arn
        },
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      }
    ]
  })
}