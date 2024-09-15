
    variable "cluster_name" {
      description = "Crisis Line Evaluation Cluster"
      type = string
    }

    resource "aws_ecs_cluster" "main" {
      name = var.cluster_name
    }

    resource "aws_ecs_task_definition" "main" {
      family                   = "crisis-test-line-eval-task"
      network_mode             = "awsvpc"
      requires_compatibilities = ["FARGATE"]
      cpu                      = "256"
      memory                   = "512"
      execution_role_arn       = module.iam.ecs_task_execution_role_arn
      
      container_definitions = jsonencode([{
        name  = "app-container"
        image = "crccheck/hello-world"
        essential = true
        portMappings = [{
          containerPort = 8000
          hostPort      = 8000
        }]
      }])
    }

    resource "aws_ecs_service" "main" {
      name            = "crisis-test-line-eval-service"
      cluster         = aws_ecs_cluster.main.id
      task_definition = aws_ecs_task_definition.main.arn
      desired_count   = 2
      launch_type     = "FARGATE"
      
      network_configuration {
        subnets         = module.vpc.private_subnets
        security_groups = [module.security_groups.ecs_sg]
        assign_public_ip = false
      }
      
      deployment_minimum_healthy_percent = 50
      deployment_maximum_percent         = 200

      load_balancer {
        target_group_arn = module.alb.target_group_arn
        container_name   = "app-container"
        container_port   = 8000
      }
      
      placement_strategy {
        type  = "spread"
        field = "attribute:ecs.availability-zone"
      }
    }

    output "cluster_arn" {
      value = aws_ecs_cluster.main.arn
    }
    