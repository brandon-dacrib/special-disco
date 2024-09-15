
    # ALB Security Group allowing port 80 access to the world
    resource "aws_security_group" "alb_sg" {
      name        = "alb_sg"
      description = "Allow inbound HTTP traffic to ALB"
      vpc_id      = module.vpc.vpc_id

      ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }

      egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    }

    # CloudWatch log group for ECS task logs
    resource "aws_cloudwatch_log_group" "ecs_task_logs" {
      name              = "/ecs/crisis-test-line-eval"
      retention_in_days = 7
    }

    # CloudWatch log group for ALB logs
    resource "aws_cloudwatch_log_group" "alb_logs" {
      name              = "/alb/crisis-test-line-eval"
      retention_in_days = 7
    }

    output "alb_sg" {
      value = aws_security_group.alb_sg.id
    }
    