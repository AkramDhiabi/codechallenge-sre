terraform {
  backend "s3" {
    bucket         = "superb-terraform-app-state"
    key            = "superb-terraform-app.tfstate"
    region         = "eu-west-3"
    encrypt        = true
    dynamodb_table = "superb-dynamodb-state-lock"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.44.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.1.0"
    }
    template = {
      source = "hashicorp/template"
      version = "2.2.0"
    }
  }
}

provider "aws" {
  region = "eu-west-3"
}

# Interpolation syntax : adjust local prefix by workspace
locals {
  prefix = terraform.workspace

  acc_id = data.aws_caller_identity.current.account_id

  region_id = data.aws_region.current.name

  # add common_tags to be applied to all resources in this project
  common_tags = {
    Environment = terraform.workspace
    Project     = var.project
    Owner       = var.contact
    ManagedBy   = "Terraform"

  }
}

# retrive the current region
data "aws_region" "current" {}

# retrive the current account caller id
data "aws_caller_identity" "current" {}