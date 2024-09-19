
# Main Terraform file for provisioning ECS, ALB, and VPC in AWS using official modules

# VPC module from terraform-aws-modules
# This module creates a VPC with public and private subnets, and enables NAT gateways for internet access
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.0"

  name = "crisis-help-eval-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-2a", "us-east-2b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway = true  # Create NAT gateways for private subnets to access the internet
  single_nat_gateway = false # Use multiple NAT gateways for high availability
}

# Security Groups module from terraform-aws-modules
# This module creates security groups for the ALB and ECS tasks
module "security_groups" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.0.0"
  
    name        = "crisis-help-eval-alb-sg"
    description = "Allow inbound HTTP traffic to ALB"
    vpc_id      = module.vpc.vpc_id

    ingress_cidr_blocks = ["0.0.0.0/0"] # Allow inbound traffic on port 80 from any IP address
    ingress_rules       = ["http-80-tcp"]
    egress_rules        = ["all-all"]

    tags = {
      Name = "crisis-help-eval-alb-sg"
    }
  }

    name        = "crisis-help-eval-ecs-sg"
    description = "ECS Task Security Group"
    vpc_id      = module.vpc.vpc_id

    ingress_cidr_blocks = [module.vpc.cidr_block] # Allow inbound traffic only from within the VPC
    ingress_rules       = ["http-8000-tcp"]       # Allow traffic on port 8000 for ECS tasks
    egress_rules        = ["all-all"]

    tags = {
      Name = "crisis-help-eval-ecs-sg"
    }
}

# ECS module from terraform-aws-modules
# This module creates an ECS cluster and deploys services using Fargate
module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "3.0.0"

  cluster_name = "crisis-help-eval-ecs" # ECS cluster name
  ecs_services = {
    service_name = "crisis-help-eval-service" # ECS service name
    task_definition = {
      container_name  = "crisis-help-eval-container"
      container_image = "crccheck/hello-world" # The Docker image for the ECS task
      container_port  = 8000                   # The container listens on port 8000
    }
    desired_count = 2         # Deploy 2 tasks for high availability
    launch_type   = "FARGATE" # Use Fargate to run the ECS tasks
  }

  subnet_ids         = module.vpc.private_subnets      # Run the ECS tasks in private subnets
  security_group_ids = [module.security_groups.ecs_sg] # Attach the ECS security group to the tasks

  tags = {
    Name = "crisis-help-eval-ecs"
  }
}

# ALB module from terraform-aws-modules
# This module creates an Application Load Balancer (ALB) to route traffic to the ECS tasks
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "7.0.0"

  name               = "crisis-help-eval-alb"          # ALB name
  load_balancer_type = "application"                   # Type of load balancer (ALB)
  subnets            = module.vpc.public_subnets       # ALB will be deployed in public subnets
  security_groups    = [module.security_groups.alb_sg] # Attach the ALB security group

  target_groups = {
    name        = "crisis-help-eval-target-group" # Target group for ECS tasks
    port        = 80                              # Forward traffic from port 80 to ECS tasks
    target_type = "ip"                            # Use IP address as the target type for ECS tasks
    vpc_id      = module.vpc.vpc_id
    health_check = {
      path = "/" # Health check for the ECS tasks
    }
  }

  listeners = {
    accept-http = {
      port     = 80
      protocol = "HTTP"
      default_action = {
        type             = "forward"
        target_group_arn = module.alb.target_groups["crisis-help-eval-target-group"].arn
      }
    }
  }

  tags = {
    Name = "crisis-help-eval-alb"
  }
}

# Output resources for easy access after provisioning
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "ecs_cluster_arn" {
  description = "ECS Cluster ARN"
  value       = module.ecs.cluster_arn
}

output "alb_dns" {
  description = "ALB DNS name"
  value       = module.alb.dns_name
}

