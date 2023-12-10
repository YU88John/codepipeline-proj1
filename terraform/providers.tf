terraform {
  required_version = "1.6.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

// https://developer.hashicorp.com/terraform/language/providers/requirements

provider "aws" {
  region  = "us-east-1"
  profile = "default"
}


