terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.17.0"
    }
  }
}

provider "aws" {
  region  = "ap-northeast-2"
}

module "vpc" {
  source = "./vpc"

  cidr = var.vpc_cidr
  azs = var.azs
  environment = var.environment
  ec2_type = var.ec2_type
  http_port = var.http_port
  ssh_port = var.ssh_port
}

module "bastion" {
  source = "./bastion"

  vpc_id = module.vpc.vpc_id
  subnet_id = module.vpc.public_subnet_id
  security_group_id = module.vpc.security_group_id
}

module "eks" {
  source = "./eks"
}