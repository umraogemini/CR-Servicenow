module "servicenow_cr" {
  source = "./modules/servicenow-cr"

  servicenow_username              = var.servicenow_username
  servicenow_password              = var.servicenow_password
  automation_ci_name               = var.automation_ci_name
  automation_ci_short_description = var.automation_ci_short_description
  user_name                        = var.user_name
  location_name                    = var.location_name
  department_name                  = var.department_name
  group_name                       = var.group_name
  custom_field_value               = var.custom_field_value
}
