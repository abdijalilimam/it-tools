terraform {
  backend "s3" {
    bucket = "it-tools-terraform-state-305476115260"
    key    = "terraform.tfstate"
    region = "us-east-2"
    dynamodb_table = "it-tools-terraform-locks"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}