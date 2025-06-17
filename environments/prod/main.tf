module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"
  
  name = "prod-vpc"
  cidr = "172.16.0.0/16" 
}

module "baseline" {
  source = "../../modules/baseline"

  vpc_id       = module.vpc.vpc_id
  environment  = "prod"
  allowed_cidr = "172.16.0.0/16"
  
  common_tags = {
    Environment = "prod"
    Team        = "platform"
    Project     = "cactus-prod"
  }
}