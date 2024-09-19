
# VPC module from terraform-aws-modules
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "crisis-help-eval-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-2a", "us-east-2b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway = true  # Create NAT gateways for private subnets to access the internet
  single_nat_gateway = false # Use multiple NAT gateways for high availability
}

# Security Group for ALB
resource "aws_security_group" "alb_security_group" {
  name        = "crisis-help-eval-alb-sg"
  description = "Allow inbound HTTP and HTTPS traffic to ALB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow HTTP traffic from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS traffic from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "crisis-help-eval-alb-sg"
  }
}

# Security Group for ECS Tasks
resource "aws_security_group" "ecs_security_group" {
  name        = "crisis-help-eval-ecs-sg"
  description = "ECS Task Security Group"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow traffic on port 8000 from ALB"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_security_group.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "crisis-help-eval-ecs-sg"
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "cth" {
  name = "crisis-help-eval-ecs"

  tags = {
    Name = "crisis-help-eval-ecs"
  }
}

# ECS Task Definition
resource "aws_ecs_task_definition" "cth" {
  family                   = "crisis-help-eval-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name      = "crisis-help-eval-container"
      image     = "crccheck/hello-world"
      essential = true
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
          protocol      = "tcp"
        }
      ]
    }
  ])

  tags = {
    Name = "crisis-help-eval-task"
  }
}

# ECS Service
resource "aws_ecs_service" "cth" {
  name            = "crisis-help-eval-service"
  cluster         = aws_ecs_cluster.cth.id
  task_definition = aws_ecs_task_definition.cth.arn
  launch_type     = "FARGATE"
  desired_count   = 2

  network_configuration {
    subnets         = module.vpc.private_subnets
    security_groups = [aws_security_group.ecs_security_group.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.cth.arn
    container_name   = "crisis-help-eval-container"
    container_port   = 8000
  }

  depends_on = [aws_lb_listener.http_listener]

  tags = {
    Name = "crisis-help-eval-service"
  }
}

# Application Load Balancer
resource "aws_lb" "cth" {
  name               = "crisis-help-eval-alb"
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.alb_security_group.id]

  tags = {
    Name = "crisis-help-eval-alb"
  }
}

# Target Group for ECS Service
resource "aws_lb_target_group" "cth" {
  name        = "crisis-help-eval-target-group"
  port        = 8000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-299"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "crisis-help-eval-target-group"
  }
}

# Listener for ALB
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.cth.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cth.arn
  }
}

# Output resources for easy access after provisioning
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "VPC CIDR Block"
  value       = module.vpc.vpc_cidr_block
}

output "ecs_cluster_arn" {
  description = "ECS Cluster ARN"
  value       = aws_ecs_cluster.cth.arn
}

output "alb_dns" {
  description = "ALB DNS name"
  value       = aws_lb.cth.dns_name
}