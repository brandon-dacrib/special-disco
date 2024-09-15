
    provider "aws" {
      region = var.aws_region
    }

    module "vpc" {
      source = "./modules/vpc"
      cidr_block = var.vpc_cidr
    }

    module "ecs" {
      source = "./modules/ecs"
      cluster_name = var.ecs_cluster_name
    }

    module "alb" {
      source = "./modules/alb"
    }

    module "iam" {
      source = "./modules/iam"
    }

    module "security_groups" {
      source = "./modules/security_groups"
    }
    