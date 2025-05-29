variable "project" {
  description = "value of the project name"
  type = string
}

variable "aws_vpc_id" {
  description = "ID of the VPC to which the subnets will be attached"
  type        = string
  
}

variable "vpc_cidr" {
  description = "value of the VPC CIDR block"
  type = string
}

variable "public_az" {
  description = "Availability zone for public subnet"
  type        = string
  default     = "eu-west-1a"
}

variable "private_az" {
  description = "Availability zone for private subnet"
  type        = string
  default     = "eu-west-1b"
}

variable "subnet_cidrs_public" {
  description = "Map of AZs to public subnet CIDRs"
  type = map(string)
}

variable "subnet_cidrs_private" {
  description = "Map of AZs to private subnet CIDRs"
  type = map(string)
}

variable "internet_gateway_id" {
  description = "ID of the Internet Gateway from VPC module"
  type        = string
}