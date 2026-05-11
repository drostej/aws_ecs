resource "aws_ecr_repository" "pond_ecr_repo" {
  name = "pond-ecr-repo"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "pond-ecr-repo"
  }
}