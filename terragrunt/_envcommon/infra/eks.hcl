terraform {
  source = "${dirname(find_in_parent_folders())}//modules/infra/eks"
}

locals {
  # Automatically load environment-level variables
  environment_vars        = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

inputs = {
  project                  = local.environment_vars.locals.project_name
  private_subnet_ids       = dependency.subnets.outputs.private_subnet_ids
  public_subnet_ids        = dependency.subnets.outputs.public_subnet_ids
  aws_vpc_id               = dependency.vpc.outputs.vpc_id
  instance_type            = local.environment_vars.locals.instance_type
  subnet_cidrs_private     = local.environment_vars.locals.subnet_cidrs_private
  node_group_min_size      = local.environment_vars.locals.node_group_min_size
  node_group_max_size      = local.environment_vars.locals.node_group_max_size
  node_group_desired_size  = local.environment_vars.locals.node_group_desired_size
  airflow_instance_type            = local.environment_vars.locals.airflow_instance_type
  airflow_node_group_min_size      = local.environment_vars.locals.airflow_node_group_min_size
  airflow_node_group_max_size      = local.environment_vars.locals.airflow_node_group_max_size
  airflow_node_group_desired_size  = local.environment_vars.locals.airflow_node_group_desired_size
  cluster_version          = local.environment_vars.locals.cluster_version

  
}


dependency "subnets" {
  config_path  = "../../network/subnets"
  skip_outputs = false
  mock_outputs = {
    private_subnet_ids = "dummy"
    public_subnet_ids = "dummy"
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
  paths = ["../../network/subnets","../../network/vpc"]
}