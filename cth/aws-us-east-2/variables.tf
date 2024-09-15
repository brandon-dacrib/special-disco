
    variable "aws_region" {
      description = "AWS Region"
      type = string
      default = "us-east-2"
    }

    variable "vpc_cidr" {
      description = "CIDR block for the VPC"
      type = string
      default = "10.0.0.0/16"
    }

    variable "ecs_cluster_name" {
      description = "ECS Cluster Name"
      type = string
      default = "crisis-test-line-eval-cluster"
    }
    