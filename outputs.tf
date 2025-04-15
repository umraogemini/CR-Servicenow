output "automation_ci_sys_id" {
  value       = module.servicenow_cr.automation_ci_sys_id
  description = "The sys_id of the created Automation CI."
}

output "automation_ci_number" {
  value       = module.servicenow_cr.automation_ci_number
  description = "The number of the created Automation CI."
}
