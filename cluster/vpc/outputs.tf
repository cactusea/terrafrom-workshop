output "vpc_id" {
  description = "VPC ID"
  value = aws_vpc.vpc.id
}

output "public_subnet_id" {
  description = "Public subnet ID"
  value = aws_subnet.public_subnet.id
}

output "public_security_group_id" {
  description = "Public security group ID"
  value = aws_security_group.public_sg.id
}

output "private_security_group_id" {
  description = "Private security group ID"
  value = aws_security_group.private_sg.id
}
