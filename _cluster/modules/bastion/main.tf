
resource "aws_security_group" "bastion_sg" {
  name = "bastion_sg"
  description = "Security group for bastion host"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port = var.basion_ssh_port
    to_port = var.basion_ssh_port
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion" {
  ami = var.ami
  instance_type = var.instance_type
  key_name = "bastion"

  subnet_id = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true
  
  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}