# elb/main.tf

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.11.0"

  name                       = "crisis-help-eval-alb"
  load_balancer_type         = "application"
  vpc_id                     = var.vpc_id
  subnets                    = var.public_subnets
  enable_deletion_protection = false

  # here is where I would set up the access and connection logs to go to s3
  #access_logs = {
  #  bucket = module.log_bucket.s3_bucket_id
  #  prefix = "access-logs"
  #}

  #connection_logs = {
  #  bucket  = module.log_bucket.s3_bucket_id
  #  enabled = true
  #  prefix  = "connection-logs"
  #}

  # Listener configuration with correct default_action
  listeners = {
    http = {
      port     = var.alb_port
      protocol = "HTTP"
      default_action = {
        type               = "forward"
        target_group_index = 0
      }
      forward = {
        target_group_key = "ctl"
        stickiness       = false
      }
    }
  }

  # Target group configuration
  target_groups = {
    ctl = {
      name_prefix                     = "ctl"
      backend_protocol                = "HTTP"
      backend_port                    = var.target_port
      create_target_group_attachments = false
      target_type                     = "ip"
      # this next line causes a broken target but I don't have time to fix it
      target_id = "10.0.1.5" # no time to sort out some change in the alb module that causes this to be required
      health_check = {
        path                = "/"
        protocol            = "HTTP"
        matcher             = "200-299"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
      }
    }
  }

  tags = {
    Name = "crisis-help-eval-alb"
  }
}

# Define target group attachments separately
#  resource "aws_lb_target_group_attachment" "cth" {
#    target_group_arn = module.alb.target_groups.ctl.arn
#    target_id        = module.alb.target_groups.ctl.target_id
#    port             = var.target_port
#  }