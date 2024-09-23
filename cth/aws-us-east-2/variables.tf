# variables.tf

variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "us-east-2"
}

variable "alb_sg_name" {
  description = "Name of the ALB security group"
  type        = string
  default     = "crisis-help-eval-alb-sg"
}

variable "ecs_sg_name" {
  description = "Name of the ECS security group"
  type        = string
  default     = "crisis-help-eval-ecs-sg"
}

variable "alb_port" {
  description = "Port for the ALB to listen on"
  type        = number
  default     = 80
}

variable "ecs_port" {
  description = "Port for the ECS tasks"
  type        = number
  default     = 8000
}

variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
  default     = "crisis-help-eval-ecs"
}

variable "task_family" {
  description = "Family name of the ECS task"
  type        = string
  default     = "crisis-help-eval-task"
}

variable "container_name" {
  description = "Name of the container in the task definition"
  type        = string
  default     = "crisis-help-eval-container"
}

variable "container_image" {
  description = "Docker image for the container"
  type        = string
  default     = "crccheck/hello-world"
}