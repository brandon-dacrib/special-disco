# vpc/main.tf

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.13.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_nat_gateway = true  # Create NAT gateways for private subnets to access the internet
  single_nat_gateway = false # Use multiple NAT gateways for high availability

  tags = {
    Name = var.vpc_name
  }
}