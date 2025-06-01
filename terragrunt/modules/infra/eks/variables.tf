variable "instance_type" {
  description = "Type of EC2 instance for the EKS node group"
  type        = string
  default     = "t3.micro"  # Free-tier eligible size
  
}

variable "airflow_instance_type" {
  description = "Type of EC2 instance for the Airflow EKS node group"
  type        = string
  
}
variable "project" {
  description = "Name of the project"
  type        = string
  
}

variable "node_group_desired_size" {
  description = "Desired number of nodes in the EKS node group"
  type        = number
  default     = 2
  
}

variable "node_group_max_size" {
  description = "Maximum number of nodes in the EKS node group"
  type        = number
  default     = 2
  
}

variable "node_group_min_size" {
  description = "Minimum number of nodes in the EKS node group"
  type        = number
  default     = 2
  
}

variable "airflow_node_group_desired_size" {
  description = "Desired number of nodes in the Airflow EKS node group"
  type        = number
  default     = 2
  
}

variable "airflow_node_group_max_size" {
  description = "Maximum number of nodes in the Airflow EKS node group"
  type        = number
  default     = 2
  
}

variable "airflow_node_group_min_size" {
  description = "Minimum number of nodes in the Airflow EKS node group"
  type        = number
  default     = 2
  
}
variable "public_subnet_ids" {
  description = "Map of public subnet IDs by availability zone"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Map of private subnet IDs by availability zone"
  type        = list(string)
}
variable "cluster_version" {
  description = "Version of the EKS cluster"
  type        = string
  default     = "1.31"  # Specify the desired EKS version
  
}

variable "aws_vpc_id" {
  description = "ID of the VPC where the EKS cluster will be created"
  type        = string
  
}

variable "subnet_cidrs_private" {
  description = "Map of AZs to private subnet CIDRs"
  type = map(string)
}
