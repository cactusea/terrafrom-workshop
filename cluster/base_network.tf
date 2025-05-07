module "base_network" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.21.0"

  name = "base-vpc"
  cidr = local.vpc_cidr

  azs = local.region
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}