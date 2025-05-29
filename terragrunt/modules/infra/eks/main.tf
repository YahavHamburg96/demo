data "http" "my_ip" {
  url = "https://checkip.amazonaws.com/"
}

locals {
  executor_ip_cidr = "${chomp(data.http.my_ip.body)}/32"
}

module "eks_al2023" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${var.project}"
  cluster_version = var.cluster_version

  # EKS Addons
  cluster_addons = {
    coredns                = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }
  
  vpc_id     = var.aws_vpc_id
  subnet_ids = [var.private_subnet_a, var.private_subnet_b]
  eks_managed_node_groups = {
    main = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      instance_types = ["${var.instance_type}"]  # Free-tier eligible size
      ami_type       = "AL2_x86_64"

      desired_size = var.node_group_desired_size
      max_size     = var.node_group_max_size
      min_size     = var.node_group_min_size
    }
  }
  enable_cluster_creator_admin_permissions = true
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access_cidrs = [local.executor_ip_cidr]

  tags = {
    Name = "${var.project}-cluster"
  }
  cluster_enabled_log_types = []      # No log types enabled
  create_cloudwatch_log_group = false
}

# module "eks" {
#   source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
#   version = "~> 20.0"

#   manage_aws_auth_configmap = true

#   aws_auth_roles = [
#     {
#       rolearn  = "arn:aws:iam::${var.user_account_id}:role/EKSAdminRole"
#       username = "eks-admin"
#       groups   = ["system:masters"]
#     }
#   ]

#   aws_auth_users = [
#     {
#       userarn  = "${var.user_arn}"
#       username = "${var.user_name}"
#       groups   = ["system:masters"]
#     }
#   ]

#   aws_auth_accounts = [
#     "${var.user_account_id}"
#   ]
# }