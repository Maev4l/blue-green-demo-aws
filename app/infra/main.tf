provider "aws" {
  region = var.region
  default_tags {
    tags = {
      "owner"       = "terraform"
      "application" = "blue-green-demo"
    }
  }
}

terraform {
  backend "s3" {
    bucket         = "bg-demo-tf-state"
    region         = "eu-central-1"
    key            = "bg-demo-app-infra/terraform.init.tfstate"
    encrypt        = "true"
    dynamodb_table = "lock-terraform-state"
  }
}

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
    "rules" : [{
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
    }]
  })
}
