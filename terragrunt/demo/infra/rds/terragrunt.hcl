include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path = "${dirname(find_in_parent_folders())}/_envcommon/infra/rds.hcl"
}

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# Ovride common inputs if needed here
# ---------------------------------------------------------------------------------------------------------------------
inputs = {

}
