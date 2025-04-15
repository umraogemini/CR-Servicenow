output "automation_ci_sys_id" {
  value = servicenow_ci.automation_creation.sys_id
  description = "The sys_id of the created Automation CI."
}

output "automation_ci_number" {
  value = servicenow_ci.automation_creation.number
  description = "The number of the created Automation CI."
}
