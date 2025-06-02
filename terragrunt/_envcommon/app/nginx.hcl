terraform {
  source = "${dirname(find_in_parent_folders())}//modules/app/nginx"
}

locals {
  # Automatically load environment-level variables
  environment_vars        = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

inputs = {
  aws_region = local.environment_vars.locals.aws_region        
  security_group_alb       = dependency.eks.outputs.security_group_alb    
  cluster_name             = dependency.eks.outputs.cluster_name
  aws_account_id           = local.environment_vars.locals.aws_account_id
}


dependency "vpc" {
  config_path  = "../../network/vpc"
  skip_outputs = false
  mock_outputs = {
    vpc_id = "dummy-vpc"
  }
}

dependency "eks" {
  config_path  = "../../infra/eks"
  skip_outputs = false
  mock_outputs = {
    security_group_alb = "dummy"
  }
}


dependencies {
  paths = ["../../network/vpc","../../infra/eks"]
}