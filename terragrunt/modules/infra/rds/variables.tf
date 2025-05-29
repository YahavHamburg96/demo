variable "project" {
  description = "Name of the project"
  type        = string
  
}


variable "private_subnet_a" {
  description = "ID of the first private subnet for the EKS node group"
  type        = string
  
}
variable "private_subnet_b" {
  description = "ID of the second private subnet for the EKS node group"
  type        = string
  
}

variable "eks_node_group_sg" {
  description = "Security group ID for the EKS node group"
  type        = string
  
}

variable "aws_vpc_id" {
  description = "ID of the VPC where the EKS cluster will be created"
  type        = string
  
}

