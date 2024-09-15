
    resource "aws_vpc" "main" {
      cidr_block = var.cidr_block
      enable_dns_support = true
      enable_dns_hostnames = true
    }

    # Internet Gateway for VPC
    resource "aws_internet_gateway" "main" {
      vpc_id = aws_vpc.main.id
    }

    # Route table for public subnet A, routing through Internet Gateway
    resource "aws_route_table" "public_route_a" {
      vpc_id = aws_vpc.main.id

      route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
      }

      tags = {
        Name = "public-route-a"
      }
    }

    # Route table for public subnet B, routing through Internet Gateway
    resource "aws_route_table" "public_route_b" {
      vpc_id = aws_vpc.main.id

      route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
      }

      tags = {
        Name = "public-route-b"
      }
    }

    # Associate public subnets with their respective route tables
    resource "aws_route_table_association" "public_subnet_a_association" {
      subnet_id      = module.vpc.public_subnet_a
      route_table_id = aws_route_table.public_route_a.id
    }

    resource "aws_route_table_association" "public_subnet_b_association" {
      subnet_id      = module.vpc.public_subnet_b
      route_table_id = aws_route_table.public_route_b.id
    }

    output "vpc_id" {
      value = aws_vpc.main.id
    }
    