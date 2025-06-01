include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path = "${dirname(find_in_parent_folders())}/_envcommon/app/airflow.hcl"
}

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# Ovride common inputs if needed here
# ---------------------------------------------------------------------------------------------------------------------
inputs = {

}
