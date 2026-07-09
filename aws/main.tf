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