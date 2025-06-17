variable "vpc_id" {
  description = "VPC ID where baseline security will be applied"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, prod)"
  type        = string
}

variable "allowed_cidr" {
  description = "CIDR block allowed to access resources"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}