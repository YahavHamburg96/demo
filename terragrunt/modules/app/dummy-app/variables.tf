variable "helm_create_namespace" {
  description = "Whether to create the namespace for the Helm release"
  type        = bool
  default     = false
  
}

variable "k8s_namespace" {
  description = "The Kubernetes namespace where the Helm release will be deployed"
  type        = string
  default     = "dummy-app"
  
}

variable "enabled" {
  description = "Enable or disable the dummy-app deployment"
  type        = bool
  default     = true
  
}
variable "values" {
  type        = string
  default     = ""
  description = "Additional yaml encoded values which will be passed to the Helm chart"
}

variable cluster_name {
  type        = string
  description = "EKS Cluster Name"
}

variable "aws_account_id" {
  description = "AWS account ID where the ECR repository will be created"
  type        = string
  
}

variable "rds_endpoint" {
  description = "Endpoint of the RDS instance for dummy-app metadata database"
  type        = string
  
}

variable "db_secret_value" {
  description = "Secret value for the dummy-app metadata database"
  type        = string
  sensitive   = true
  
}