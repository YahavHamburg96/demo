variable "private_subnet_a" {
  description = "ID of the first private subnet for the EKS node group"
  type        = string
  
}
variable "private_subnet_b" {
  description = "ID of the second private subnet for the EKS node group"
  type        = string
  
}

variable "aws_vpc_id" {
  description = "ID of the VPC where the EKS cluster will be created"
  type        = string
  
}

variable "aws_region" {
  description = "AWS region where the ECR repository will be created"
  type        = string
  default     = "eu-west-1"  # Default to Ireland region
  
}

variable "project" {
  description = "Name of the project"
  type        = string
  
}

variable "aws_account_id" {
  description = "AWS account ID where the ECR repository will be created"
  type        = string
  
}

variable "ecr_repositories" {
  description = "Map of ECR repositories to create, where the key is the repository name and the value is an object with additional properties if needed"
  type        = map(object({
    # Add any additional properties for the ECR repository here if needed
  }))
  default     = {
    "dummy-app" = {}
    "airflow" = {}
    "redis" = {}
  }
  
}