# setting a global default for the region variable on purpose
variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "us-east-2"
}

variable "bucket_name" {
  description = "The name of the S3 bucket for storing the Terraform state."
  type        = string
  default     = "you-forgot-to-set-this-var-in-terraform-dot-tfvars"
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table for Terraform state locking."
  type        = string
  default     = "you-forgot-to-set-this-var-in-terraform-dot-tfvars"
}

variable "state_key" {
  description = "The key (path) in the S3 bucket where the Terraform state will be stored."
  type        = string
  default     = "you-forgot-to-set-this-var-in-terraform-dot-tfvars"
}