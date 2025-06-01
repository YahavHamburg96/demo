variable "project" {
  description = "Name of the project"
  type        = string
  
}


variable "private_subnet_ids" {
  description = "Map of private subnet IDs by availability zone"
  type        = list(string)
}
variable "eks_node_group_sg" {
  description = "Security group ID for the EKS node group"
  type        = string
  
}

variable "aws_vpc_id" {
  description = "ID of the VPC where the EKS cluster will be created"
  type        = string
  
}

