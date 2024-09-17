
provider "aws" {
  region = var.aws_region
}

# Create an S3 bucket to store the Terraform state
resource "aws_s3_bucket" "special-disco" {
  bucket = "special-disco"

  tags = {
    Name = "tf state bucket for assignments"
  }
}

resource "aws_s3_bucket_versioning" "special-disco" {
  bucket = aws_s3_bucket.special-disco.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "special-disco" {
  bucket = aws_s3_bucket.special-disco.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "special-disco" {
  depends_on = [aws_s3_bucket_ownership_controls.special-disco]

  bucket = aws_s3_bucket.special-disco.id
  acl    = "private"
}

# Create a DynamoDB table for state locking
resource "aws_dynamodb_table" "special-disco" {
  name         = "special-disco"
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
  value = aws_s3_bucket.special-disco.bucket
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.special-disco.name
}
