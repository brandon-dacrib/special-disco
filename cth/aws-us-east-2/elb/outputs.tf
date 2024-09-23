# elb/outputs.tf

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = module.alb.dns_name
}

output "target_group_arn" {
  description = "ARN of the ALB target group"
  value       = module.alb.target_groups.ctl.arn
}