# ecs/main.tf

# Create an ECS cluster
resource "aws_ecs_cluster" "cth" {
  name = var.cluster_name

  tags = {
    Name = var.cluster_name
  }
}

# Create an ECS task definition
resource "aws_ecs_task_definition" "cth" {
  family                   = var.task_family
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = var.container_image
      essential = true
      portMappings = [
        {
          containerPort = var.ecs_port
          hostPort      = var.ecs_port
          protocol      = "tcp"
        }
      ]
    }
  ])

  tags = {
    Name = var.task_family
  }
}

# Create an ECS service
resource "aws_ecs_service" "cth" {
  name            = "${var.cluster_name}-service"
  cluster         = aws_ecs_cluster.cth.id
  task_definition = aws_ecs_task_definition.cth.arn
  launch_type     = "FARGATE"
  desired_count   = 2

  network_configuration {
    subnets         = var.private_subnets
    security_groups = [var.ecs_security_group_id]
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = var.container_name
    container_port   = var.ecs_port
  }

  depends_on = [aws_ecs_task_definition.cth]

  tags = {
    Name = "${var.cluster_name}-service"
  }
}