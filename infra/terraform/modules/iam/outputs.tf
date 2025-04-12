output "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = aws_iam_role.ecs_task_execution.arn
}

output "ecs_task_role_arn" {
  description = "ARN of the ECS task role"
  value       = aws_iam_role.ecs_task.arn
}

output "ci_cd_role_arn" {
  description = "ARN of the CI/CD role for GitHub Actions"
  value       = aws_iam_role.ci_cd.arn
}

/* output "dockerhub_secret_arn" {
  description = "ARN of Docker Hub credentials secret"
  value       = aws_secretsmanager_secret.dockerhub.arn
}

*/