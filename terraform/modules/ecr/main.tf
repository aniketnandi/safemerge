# One private ECR repository per image.
resource "aws_ecr_repository" "repo" {
  for_each = toset(var.repositories)

  name = each.value
  # Tags are commit SHAs and can never be overwritten
  image_tag_mutability = "IMMUTABLE"
  # Allows terraform destroy to remove repos that still hold images (lab rebuilds)
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

# Keep only the 10 newest images in each repository, to limit storage cost
resource "aws_ecr_lifecycle_policy" "keep_last_10" {
  for_each   = aws_ecr_repository.repo
  repository = each.value.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep the 10 most recent images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
      action = { type = "expire" }
    }]
  })
}
