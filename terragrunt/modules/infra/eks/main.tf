
# Cluster access Only
data "http" "my_ip" {
  url = "https://checkip.amazonaws.com/"
}


resource "aws_security_group" "alb" {
  name        = "${var.project}-alb-sg"
  description = "Allow HTTP/HTTPS from user"
  vpc_id      = var.aws_vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-alb-sg"
  }
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


resource "aws_security_group_rule" "allow_alb_to_nodes_https" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = module.eks_al2023.node_security_group_id
}

