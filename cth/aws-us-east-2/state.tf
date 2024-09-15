
    terraform {
      backend "s3" {
        bucket = "special-disco"
        key    = "ctl/terraform.tfstate"
        region = "us-east-2"
        dynamodb_table = "special-disco-ctl-tflock"
        encrypt = true
      }
    }
    