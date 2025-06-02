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
    "prometheus/statsd-exporter" = {}
    "postgresql" = {}
    "ingress-nginx/controller" = {}
    "ingress-nginx/kube-webhook-certgen" = {}
  }
  
}

variable "private_subnet_ids" {
  description = "Map of private subnet IDs by availability zone"
  type        = list(string)
}