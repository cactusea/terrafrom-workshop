locals {
  vpc_id = aws_vpc.vpc.id
  vpc_cidr = "10.0.0.0/16"
  environment = "dev"
  region = "ap-northeast-2"
  azs = ["ap-northeast-2a", "ap-northeast-2c"]
}

resource "aws_vpc" "vpc" {
  cidr_block = var.cidr

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

# internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

# public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

# nat gateway
resource "aws_eip" "eip" {
  domain = "vpc"
}

# private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

# route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# route table association
resource "aws_route_table_association" "public_route_table_association" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_route_table_association" {
  subnet_id = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

# security group
resource "aws_security_group" "alb_sg" {
  name = "alb_sg"
  description = "Security group for alb"
  vpc_id = aws_vpc.vpc.id

  # HTTP
  ingress {
    from_port = var.http_port
    to_port = var.http_port
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  # ingress {
  #   from_port = var.https_port
  #   to_port = var.https_port
  #   protocol = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # ALL
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "public_sg" {
  name = "public_sg"
  description = "Security group for public subnet"
  vpc_id = aws_vpc.vpc.id

  # ALB의 HTTP 트래픽
  ingress {
    from_port = var.http_port
    to_port = var.http_port
    security_groups = [aws_security_group.alb_sg.id]
    protocol = "tcp"
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private_sg" {
  name = "private_sg"
  description = "Security group for private subnet"
  vpc_id = aws_vpc.vpc.id
  
  ingress {
    from_port = var.http_port
    to_port = var.http_port
    security_groups = [aws_security_group.public_sg.id]
    protocol = "tcp"
  }
  
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --------

# ALB
resource "aws_lb" "alb" {
  name = "alb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb_sg.id]
  subnets = [aws_subnet.public_subnet.id]

  enable_deletion_protection = true
}

# ACL
resource "aws_network_acl" "public_acl" {
  vpc_id = aws_vpc.vpc.id
  subnet_ids = [aws_subnet.public_subnet.id]
  
}

# EC2
resource "aws_instance" "workshop-dev" {
  ami = "ami-aaaa"
  instance_type = "t3.micro"
  key_name = "bastion"
  subnet_id = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.public_sg.id]

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}