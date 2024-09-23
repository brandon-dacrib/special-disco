# elb/variables.tf

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "alb_security_group" {
  description = "ID of the ALB security group"
  type        = string
}

variable "alb_port" {
  description = "Port for the ALB to listen on"
  type        = number
}

variable "target_port" {
  description = "Port the ALB forwards traffic to"
  type        = number
}

variable "ecs_service_id" {
  description = "ID of the ECS service"
  type        = string
}