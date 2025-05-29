terraform {
  source = "${dirname(find_in_parent_folders())}//modules/infra/rds"
}

locals {
  # Automatically load environment-level variables
  environment_vars        = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

inputs = {
  project                  = local.environment_vars.locals.project_name
  private_subnet_a         = dependency.subnets.outputs.private_subnet_a
  private_subnet_b         = dependency.subnets.outputs.private_subnet_b
  aws_vpc_id               = dependency.vpc.outputs.vpc_id
  eks_node_group_sg      = dependency.eks.outputs.eks_node_group_sg
 
  
}


dependency "eks" {
  config_path  = "../eks"
  skip_outputs = false
  mock_outputs = {
    eks_node_group_sg = "dummy"
  }
}

dependency "subnets" {
  config_path  = "../../network/subnets"
  skip_outputs = false
  mock_outputs = {
    private_subnet_a = "dummy"
    private_subnet_b = "dummy"
  }
}

dependency "vpc" {
  config_path  = "../../network/vpc"
  skip_outputs = false
  mock_outputs = {
    vpc_id = "dummy-vpc"
  }
}

dependencies {
  paths = ["../../network/subnets","../../network/vpc","../eks"]
}