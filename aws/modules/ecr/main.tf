#added immutable so that the image stay the same.
resource "aws_ecr_repository" "main" {
  name                 = var.repository_name
  image_tag_mutability = "IMMUTABLE"

tags = {
Name = var.repository_name
}
}