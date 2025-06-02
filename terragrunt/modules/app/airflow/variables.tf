variable "helm_create_namespace" {
  description = "Whether to create the namespace for the Helm release"
  type        = bool
  default     = false
  
}

variable "helm_chart_version" {
  description = "Version of the Helm chart to deploy"
  type        = string
  default     = "1.16.0"  # Update this to the desired version of the Airflow Helm chart
  
}

variable "k8s_namespace" {
  description = "The Kubernetes namespace where the Helm release will be deployed"
  type        = string
  default     = "airflow"
  
}

variable "enabled" {
  description = "Enable or disable the Airflow deployment"
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


