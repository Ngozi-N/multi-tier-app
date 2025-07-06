terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Use a compatible version
    }
  }
  required_version = ">= 1.0.0"

  backend "s3" {
    bucket         = "terraform-state-bucket-ngozi" # Replace with a unique S3 bucket name
    key            = "multi-tier-app/terraform.tfstate"
    region         = "eu-west-2" # Match your desired AWS region
    use_lockfile   = true # A DynamoDB table for state locking
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}