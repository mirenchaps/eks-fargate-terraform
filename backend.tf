terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket  = "cisco-device-automation-tfstate"
    key     = "eks/dev/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
