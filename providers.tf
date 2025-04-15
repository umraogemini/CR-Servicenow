terraform {
  required_providers {
    servicenow = {
      source = "devoteamgckoud/servicenow"
      version = ">= 0.1.4"
    }
  }
}

provider "servicenow" {
  instance_url = var.servicenow_instance_url
  username     = var.servicenow_username
  password     = var.servicenow_password
}
