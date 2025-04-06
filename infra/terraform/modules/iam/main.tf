# IAM Roles for Metabase on AWS
# Least-privilege permissions for ECS, RDS, and CI/CD

resource "aws_iam_role" "ecs_task_execution" {
  name               = "metabase-ecs-task-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Policy for Secrets Manager (DB credentials)
resource "aws_iam_policy" "ecs_secrets_access" {
  name        = "metabase-ecs-secrets-access"
  description = "Allow ECS to fetch DB credentials from Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action   = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      Effect   = "Allow",
      Resource = aws_secretsmanager_secret.db_credentials.arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_secrets" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = aws_iam_policy.ecs_secrets_access.arn
}

# Task Role for Metabase

resource "aws_iam_role" "ecs_task" {
  name               = "metabase-ecs-task-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

# Minimal S3 permissions (L'export l S3)
resource "aws_iam_policy" "metabase_s3" {
  name        = "metabase-s3-export-access"
  description = "Allow Metabase to write to S3 for exports"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action   = [
        "s3:PutObject",
        "s3:GetObject"
      ],
      Effect   = "Allow",
      Resource = "arn:aws:s3:::metabase-exports/*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_s3" {
  count      = var.enable_s3_exports ? 1 : 0  # Mtnsach dir enable l Dashboard Exports through S3 buckets
  role       = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.metabase_s3.arn
}

# CI/CD GitHub role 

resource "aws_iam_role" "ci_cd" {
  name               = "metabase-github-actions-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRoleWithWebIdentity",
      Effect    = "Allow",
      Principal = {
        Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
      },
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com",
          "token.actions.githubusercontent.com:sub" = "repo:https://github.com/mrmeddah/pipelock-starter:ref:refs/heads/main"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ci_cd_ecr" {
  role       = aws_iam_role.ci_cd.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_role_policy_attachment" "ci_cd_ecs" {
  role       = aws_iam_role.ci_cd.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"  # 9ad access l specified clusters later fech twsel L'CI/CD
}

# Resources

resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "metabase-db-credentials"
  description = "RDS PostgreSQL credentials for Metabase"
}

data "aws_caller_identity" "current" {}

#Define clusters aprés L CI/CD
#Mtnsach Secrets Manager w Variables file. (done)

