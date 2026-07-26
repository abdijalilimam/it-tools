#ECR
resource "aws_ecr_repository" "main" {
  name                 = "it-tools"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true

  tags = {
    Name = "it-tools"
  }
}
# OIDC Provider - allows GitHub Actions to authenticate with AWS
#had to add life cycle to prevent it to from deleting when doing terrafrom destroy 

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

  /*lifecycle {
    prevent_destroy = true
  }
  */
}
# IAM Role - grants GitHub Actions temporary access to AWS resources
resource "aws_iam_role" "github_actions" {
  name = "github-actions-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:abdijalilimam/it-tools:*"
        }
      }
    }]
  })
 /*lifecycle {
    prevent_destroy = true
  }
  */
}

#The role needs permission for these 2 actions:
resource "aws_iam_role_policy_attachment" "github_actions_ecr" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}
resource "aws_iam_role_policy_attachment" "github_actions_admin" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}