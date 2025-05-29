terraform {
  source = "${dirname(find_in_parent_folders())}//modules/network/subnets"
}

locals {
  # Automatically load environment-level variables
  environment_vars        = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

inputs = {
  project                  = local.environment_vars.locals.project_name
  vpc_cidr                 = local.environment_vars.locals.vpc_cidr
  subnet_cidrs_public       = local.environment_vars.locals.subnet_cidrs_public
  subnet_cidrs_private      = local.environment_vars.locals.subnet_cidrs_private
  aws_vpc_id               = dependency.vpc.outputs.vpc_id
  internet_gateway_id      = dependency.vpc.outputs.internet_gateway_id
  
}


dependency "vpc" {
  config_path  = "../vpc"
  skip_outputs = false
  mock_outputs = {
    vpc_id = "dummy-vpc"
    internet_gateway_id = "dummy-igw"
  }
}

dependencies {
  paths = ["../vpc"]
}