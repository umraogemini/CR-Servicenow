variable "automation_ci_name" {
  type = string
}

variable "automation_ci_short_description" {
  type = string
}

variable "user_name" {
  type = string
  default = ""
}

variable "location_name" {
  type = string
  default = ""
}

variable "department_name" {
  type = string
  default = ""
}

variable "group_name" {
  type = string
  default = ""
}

variable "custom_field_value" {
  type = string
  default = ""
}

variable "servicenow_username" {
  type = string
  sensitive = true
}

variable "servicenow_password" {
  type = string
  sensitive = true
}
