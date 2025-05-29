## Auto generated terragrunt.hcl ##
## Updated on:  ##

# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  project_name        = local.environment_vars.locals.project_name
  state_bucket_name   = local.environment_vars.locals.backend.bucket
  state_key           = local.environment_vars.locals.backend.key
  dynamodb_table      = local.environment_vars.locals.backend.dynamodb_table
  # Extract the variables we need for easy access
  aws_region = local.environment_vars.locals.aws_region

}

# Generate an AWS provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"
  default_tags {
    tags = {
      project = "${local.project_name}"
    }
  }
}
EOF
}

remote_state {
  backend = "s3"
  config = {
    region         = "${local.aws_region}"
    bucket         = "terrafrom-state-${local.project_name}-934571"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    dynamodb_table = "terraform-locks"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}


generate "versions" {
  path      = "versions_override.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
    terraform {
      required_providers {
        aws = {
          source  = "hashicorp/aws"
          version = "5.98.0"
        }
      }
    }
EOF
}

