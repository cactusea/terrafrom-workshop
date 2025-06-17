locals {
  region = "ap-northeast-2"
  vpc_id = "vpc-1234"
  vpc_cidr = "10.0.0.0/16"
  allowed_cidr = "0.0.0.0/0"
  common_tags = {
    Environment = "dev"
    Project = "terraform-eks"
  }
}