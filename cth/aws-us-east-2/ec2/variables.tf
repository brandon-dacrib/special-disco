# ec2/variables.tf

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "alb_sg_name" {
  description = "Name of the ALB security group"
  type        = string
}

variable "ecs_sg_name" {
  description = "Name of the ECS security group"
  type        = string
}

variable "alb_port" {
  description = "Port for the ALB"
  type        = number
}

variable "ecs_port" {
  description = "Port for the ECS tasks"
  type        = number
}