# ec2/main.tf

# Create security group for ALB
module "alb_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.2.0"

  name        = var.alb_sg_name
  description = "Security group for the ALB"
  vpc_id      = var.vpc_id

  ingress_rules       = ["http-80-tcp", "https-443-tcp"] # Allow HTTP and HTTPS
  ingress_cidr_blocks = ["0.0.0.0/0"]                    # From anywhere

  egress_rules = ["all-all"] # Allow all outbound traffic

  tags = {
    Name = var.alb_sg_name
  }
}

# Create security group for ECS tasks
module "ecs_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.2.0"

  name        = var.ecs_sg_name
  description = "Security group for ECS tasks"
  vpc_id      = var.vpc_id

  ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      from_port                = var.ecs_port
      to_port                  = var.ecs_port
      source_security_group_id = module.alb_security_group.security_group_id
      description              = "Allow traffic from ALB"
    }
  ]

  egress_rules = ["all-all"] # Allow all outbound traffic

  tags = {
    Name = var.ecs_sg_name
  }
}