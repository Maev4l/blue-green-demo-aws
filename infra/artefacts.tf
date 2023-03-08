

locals {
  repositories = [
    "demo/blue-green",
  ]
}

resource "aws_ecr_repository" "repositories" {
  for_each     = toset(local.repositories)
  name         = each.value
  force_delete = true
}

resource "aws_ecr_lifecycle_policy" "repositories_lifecycle" {
  for_each   = aws_ecr_repository.repositories
  repository = each.value.name
  policy = jsonencode({
    "rules" : [
      {
        "rulePriority" : 1,
        "description" : "Expire untagged images older than 3 days",
        "selection" : {
          "tagStatus" : "untagged",
          "countType" : "sinceImagePushed",
          "countUnit" : "days",
          "countNumber" : 3
        },
        "action" : {
          "type" : "expire"
        }
      }
    ]
    }
  )
}
