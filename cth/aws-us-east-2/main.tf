# main.tf

# Specify the AWS provider
provider "aws" {
  region = var.aws_region
}

# Include the VPC module
module "vpc" {
  source = "./vpc"
}

# Include the Security Groups module
module "ec2" {
  source      = "./ec2"
  vpc_id      = module.vpc.vpc_id
  alb_sg_name = var.alb_sg_name
  ecs_sg_name = var.ecs_sg_name
  alb_port    = var.alb_port
  ecs_port    = var.ecs_port
}

# Include the ALB module
module "alb" {
  source             = "./elb"
  vpc_id             = module.vpc.vpc_id
  public_subnets     = module.vpc.public_subnets
  alb_security_group = module.ec2.alb_security_group_id
  alb_port           = var.alb_port
  target_port        = var.ecs_port
  ecs_service_id     = module.ecs.ecs_service_id
}

# Include the ECS module
module "ecs" {
  source                = "./ecs"
  cluster_name          = var.cluster_name
  task_family           = var.task_family
  container_name        = var.container_name
  container_image       = var.container_image
  ecs_security_group_id = module.ec2.ecs_security_group_id
  private_subnets       = module.vpc.private_subnets
  alb_target_group_arn  = module.alb.target_group_arn
  ecs_port              = var.ecs_port
}