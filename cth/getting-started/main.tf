
provider "aws" {
  region = var.aws_region
}

# Create an S3 bucket to store the Terraform state
resource "aws_s3_bucket" "terraform_state" {
  bucket = "my-tf-state-bucket"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = {
    Name = "Terraform State Bucket"
  }
}

# Create a DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_lock" {
  name         = "terraform-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "Terraform Lock Table"
  }
}

output "s3_bucket_name" {
  value = aws_s3_bucket.terraform_state.bucket
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.terraform_lock.name
}
