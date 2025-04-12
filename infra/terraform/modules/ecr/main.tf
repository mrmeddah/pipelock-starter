
resource "aws_ecr_repository" "metabase" {
  name = "metabase"
}

resource "aws_ecr_lifecycle_policy" "metabase" {
  repository = aws_ecr_repository.metabase.name
  policy = jsonencode({
    rules = [{
      rulePriority = 1,
      description  = "Keep last 10 images",
      selection = {
        tagStatus   = "any",
        countType   = "imageCountMoreThan",
        countNumber = 10
      },
      action = { type = "expire" }
    }]
  })
}
