
variable "aws_region" {
  description = "AWS region where the ECR repository will be created"
  type        = string
  default     = "eu-west-1"  # Default to Ireland region
  
}

variable "security_group_alb" {
  description = "Security group ID for the ALB"
  type        = string
  
}

variable cluster_name {
  type        = string
  description = "EKS Cluster Name"
}

variable "aws_account_id" {
  description = "AWS account ID where the ECR repository will be created"
  type        = string
  
}