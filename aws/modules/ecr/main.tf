#added immutable so that the image stay the same.
#force deletion 
resource "aws_ecr_repository" "main" {
  name                 = var.repository_name
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true
lifecycle {
    prevent_destroy = true
  }
  tags = {
    Name = var.repository_name
  }
}