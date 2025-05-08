
variable "vpc_id" {
  type = string
  description = "VPC ID"
}

variable "subnet_id" {
  type = string
  description = "Subnet ID"
}

variable "security_group_id" {
  type = string
  description = "Security Group ID"
}

variable "ami" {
  type = string
  description = "AMI ID"
  default = "ami-047a51fa8d1700379"
}

variable "instance_type" {
  type = string
  description = "Instance type"
  default = "t3.micro"
}

variable "basion_ssh_port" {
  type = number
  description = "Basion SSH port"
  default = 22
}