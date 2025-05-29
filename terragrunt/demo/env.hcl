locals {
  # Terrafrom backend configuration
  backend = {
    region         = "${local.aws_region}"
    bucket         = "terrafrom-state-${local.project_name}-934571"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    dynamodb_table = "terraform-locks"
  }

  # Environment configuration
  project_name             = "demo"
  aws_region               = "eu-west-1"
  aws_account_id           = 851725660327

  # Network
  vpc_cidr                 = "10.0.0.0/20"
  subnet_cidrs_public  = {
        "eu-west-1a" = "10.0.0.0/22"
        "eu-west-1b" = "10.0.4.0/22"
  }
  subnet_cidrs_private = {
        "eu-west-1a" = "10.0.8.0/22" 
        "eu-west-1b" = "10.0.12.0/22"
  }

  # EKS
  instance_type           = "t3.micro"
  node_group_min_size     = 2
  node_group_max_size     = 2
  node_group_desired_size = 2
  cluster_version         = "1.31"

  
}