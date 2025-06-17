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
  source = "./modules/vpc"
  # source = "terraform-aws-modules/vpc/aws"
  # version = "5.19.0"

  cidr = var.vpc_cidr
  azs = var.azs
  environment = var.environment
  ec2_type = var.ec2_type
  http_port = var.http_port
  ssh_port = var.ssh_port
}

module "baseline" {
  source = "../../modules/baseline"

  vpc_id = module.vpc.vpc_id
  environment = var.environment
  allowed_cidr = var.vpc_cidr
  common_tags = {
    Environment = "dev"
    Team        = "platform"
    Project     = "cactus-dev"
  }
}

module "bastion" {
  source = "./modules/bastion"

  vpc_id = module.vpc.vpc_id
  subnet_id = module.vpc.public_subnet_id
  security_group_id = module.vpc.security_group_id
}

module "eks" {
  source = "./modules/eks"
  # source = "terraform-aws-modules/eks/aws"
  # version = "~>20.31"

}

# module "irsa" {}

module "rds" {
  source = "./modules/rds"
  # source = "terraform-aws-modules/rds/aws"
  # version = "5.1.0"

  vpc_id = module.vpc.vpc_id
  subnet_id = module.vpc.public_subnet_id
  security_group_id = module.vpc.security_group_id
}

module "sns" {
  source = "terraform-aws-modules/sns/aws"
  version = "5.1.0"

  name = "dev-sns"
  tags = {
    Environment = "dev"
  }
}

module "sqs-dev-1" {
  source = "terraform-aws-modules/sqs/aws"
  version = "5.1.0"

  name = "dev-sqs-1"
  create_queue_policy = true
  sqs_managed_sse_enabled = false
  queue_policy_statements = {
    owner_statement = {
      sid     = "__owner_statement"
      effect  = "Allow"
      actions = ["SQS:*"]
      principals = [
        {
          type        = "AWS"
          identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
        }
      ]
    },
    sns_statement = {
      sid     = "topic-subscription-arn:aws:sns:ap-northeast-2:${data.aws_caller_identity.current.account_id}:sn-events-dev-v2"
      effect  = "Allow"
      actions = ["SQS:SendMessage"]
      principals = [
        {
          type        = "AWS"
          identifiers = ["*"]
        }
      ]
      conditions = [
        {
          test     = "ArnLike"
          variable = "aws:SourceArn"
          values   = ["arn:aws:sns:ap-northeast-2:${data.aws_caller_identity.current.account_id}:sn-events-dev-v2"]
        }
      ]
    }
  }
  tags = {
    Environment = "dev"
  }
}

module "sqs-dev-2" {
  source = "terraform-aws-modules/sqs/aws"
  version = "5.1.0"

  name = "dev-sqs-2"
  create_queue_policy = true
  sqs_managed_sse_enabled = false
  queue_policy_statements = {
    owner_statement = {
      sid     = "__owner_statement"
      effect  = "Allow"
      actions = ["SQS:*"]
      principals = [
        {
          type        = "AWS"
          identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
        }
      ]
    },
    sns_statement = {
      sid     = "topic-subscription-arn:aws:sns:ap-northeast-2:${data.aws_caller_identity.current.account_id}:sn-events-dev-v2"
      effect  = "Allow"
      actions = ["SQS:SendMessage"]
      principals = [
        {
          type        = "AWS"
          identifiers = ["*"]
        }
      ]
      conditions = [
        {
          test     = "ArnLike"
          variable = "aws:SourceArn"
          values   = ["arn:aws:sns:ap-northeast-2:${data.aws_caller_identity.current.account_id}:sn-events-dev-v2"]
        }
      ]
    }
  }
  tags = {
    Environment = "dev"
  }
}

resource "aws_sns_topic_subscription" "sqs-dev-1-subscription" {
  topic_arn = module.sns.arn
  protocol = "sqs"
  endpoint = module.sqs-dev-1.arn
}

resource "aws_sns_topic_subscription" "sqs-dev-2-subscription" {
  topic_arn = module.sns.arn
  protocol = "sqs"
  endpoint = module.sqs-dev-2.arn
}
