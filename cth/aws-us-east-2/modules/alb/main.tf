
    resource "aws_lb" "main" {
      name               = "crisis-test-line-eval-alb"
      internal           = false
      load_balancer_type = "application"
      security_groups    = [module.security_groups.alb_sg]
      subnets            = module.vpc.public_subnets
    }

    output "dns_name" {
      value = aws_lb.main.dns_name
    }
    