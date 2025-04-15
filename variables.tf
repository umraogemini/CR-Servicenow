variable "servicenow_instance_url" {
  type        = string
  description = "ServiceNow instance URL"
}

variable "servicenow_username" {
  type        = string
  sensitive   = true
  description = "ServiceNow username"
}

variable "servicenow_password" {
  type        = string
  sensitive   = true
  description = "ServiceNow password"
}

variable "automation_ci_name" {
  type        = string
  default     = "Terraform Managed Automation CI"
}

variable "automation_ci_short_description" {
  type        = string
  default     = "Automation CI created by Terraform"
}

variable "user_name" {
  type    = string
  default = ""
}

variable "location_name" {
  type    = string
  default = ""
}

variable "department_name" {
  type    = string
  default = ""
}

variable "group_name" {
  type    = string
  default = ""
}

variable "custom_field_value" {
  type    = string
  default = "custom value"
}
