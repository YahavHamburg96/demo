terraform {
  source = "${dirname(find_in_parent_folders())}//modules/network/vpc"
}

locals {
  # Automatically load environment-level variables
  environment_vars        = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

inputs = {
  project                  = local.environment_vars.locals.project_name
  vpc_cidr                 = local.environment_vars.locals.vpc_cidr
}
