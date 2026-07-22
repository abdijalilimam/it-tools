module "ecr" {
  source          = "./modules/ecr"
  repository_name = var.project_name
}
module "vpc" {
  source              = "./modules/vpc"
  vpc_name            = var.project_name
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  availability_zone   = var.availability_zone
}
module "acm" {
  source          = "./modules/acm"
  domain_name = var.domain_name
}

module "alb" {
  source            = "./modules/alb"
  alb_name           = var.project_name
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  certificate_arn = module.acm.certificate_arn
}

module "ecs" { 
  source = "./modules/ecs" 
  ecs_name = var.project_name 
  vpc_id = module.vpc.vpc_id 
  private_subnet_ids = module.vpc.private_subnet_ids 
  container_image = var.container_image 
  cpu = var.cpu 
  memory = var.memory 
  target_group_arn = module.alb.target_group_arn
  alb_security_group_id = module.alb.alb_security_group_id
}

# OIDC Provider - allows GitHub Actions to authenticate with AWS
#had to add life cycle to prevent it to from deleting when doing terrafrom destroy 
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

  lifecycle {
    prevent_destroy = true
    }
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
  lifecycle {
    prevent_destroy = true
  }
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