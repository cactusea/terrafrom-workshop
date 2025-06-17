variable "cidr" {
  type = string
  description = "VPC CIDR"
  default = "10.0.0.0/16"
}

variable "region" {
  type = string
  description = "Region"
  default = "ap-northeast-2"
}

variable "azs" {
  type = list(string)
  description = "Availability zones"
  default = ["ap-northeast-2a", "ap-northeast-2c"]
}

variable "environment" {
  type = string
  description = "Environment"
  default = "dev"
}

variable "ec2_type" {
  type = string
  description = "EC2 type"
  default = "t3.micro"
}

variable "http_port" {
  type = number
  description = "HTTP port"
  default = 80
}

variable "ssh_port" {
  type = number
  description = "SSH port"
  default = 22
} 

variable "https_port" {
  type = number
  description = "HTTPS port"
  default = 443
}

