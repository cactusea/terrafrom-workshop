variable "region" {
  type = string
}

variable "component" {}

variable "deployment_identifier" {}

variable "availability_zones" {
  type = list(string)
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "domain_name" {
  type = string
  description = "Domain name"
}

variable "azs" {
  description = "Availability zones"
  type        = list(string)
  default     = ["ap-northeast-2a", "ap-northeast-2c"]
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "ec2_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "http_port" {
  description = "HTTP port"
  type        = number
  default     = 80
}

variable "ssh_port" {
  description = "SSH port"
  type        = number
  default     = 22
}