resource "servicenow_ci" "automation_creation" {
  table               = "cmdb_ci_automation"
  short_description   = var.automation_ci_short_description
  name                = var.automation_ci_name
  operational_status  = 1
  install_status      = 1
  discovery_source    = "Terraform"
  assigned_to         = null
  location            = null
  department          = null
  support_group       = null
  u_custom_field      = var.custom_field_value
}
