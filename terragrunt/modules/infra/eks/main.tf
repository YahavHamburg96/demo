data "http" "my_ip" {
  url = "https://checkip.amazonaws.com/"
}


module "eks_al2023" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${var.project}"
  cluster_version = var.cluster_version

  # EKS Addons
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }
  
  vpc_id     = var.aws_vpc_id
  subnet_ids = concat(var.public_subnet_ids, var.private_subnet_ids)
  eks_managed_node_groups = {
    main = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      instance_types = ["${var.instance_type}"]  # Free-tier eligible size
      ami_type       = "AL2_x86_64"
      iam_role_additional_policies = {
         "AmazonEBSCSIDriverPolicy" = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      }
      desired_size = var.node_group_desired_size
      max_size     = var.node_group_max_size
      min_size     = var.node_group_min_size
      subnet_ids   = var.private_subnet_ids
    }
    airflow = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      instance_types = ["${var.airflow_instance_type}"]  # Free-tier eligible size
      ami_type       = "AL2_x86_64"

      desired_size = var.airflow_node_group_desired_size
      max_size     = var.airflow_node_group_max_size
      min_size     = var.airflow_node_group_min_size
      subnet_ids   = var.private_subnet_ids
      labels = {
        "airflow" = "true"
      }
      iam_role_additional_policies = {
         "AmazonEBSCSIDriverPolicy" = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      }
      taints = {
        dedicated = {
          key    = "dedicated"
          value  = "airflow"
          effect = "NO_SCHEDULE"
        }
      }
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
