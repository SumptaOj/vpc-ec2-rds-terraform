terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  profile = "dev"
  region  = "eu-central-1"
}

data "aws_availability_zones" "available" {
  state = "available"
}

  