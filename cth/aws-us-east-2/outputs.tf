
    output "vpc_id" {
      description = "VPC ID"
      value = module.vpc.vpc_id
    }

    output "ecs_cluster_arn" {
      description = "ECS Cluster ARN"
      value = module.ecs.cluster_arn
    }

    output "alb_dns" {
      description = "ALB DNS name"
      value = module.alb.dns_name
    }
    