# ecs/iam.tf

# Create IAM role for ECS task execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.cluster_name}-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_assume_role_policy.json

  tags = {
    Name = "${var.cluster_name}-execution-role"
  }
}

# Define the assume role policy document
data "aws_iam_policy_document" "ecs_task_execution_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Attach AWS managed policies to the role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Create IAM role for ECS task
resource "aws_iam_role" "ecs_task_role" {
  name               = "${var.cluster_name}-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role_policy.json

  tags = {
    Name = "${var.cluster_name}-task-role"
  }
}

# Define the assume role policy document for task role
data "aws_iam_policy_document" "ecs_task_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}