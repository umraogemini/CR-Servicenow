### CR-Servicenow/main.tf
module "servicenow_cr" {
  source = "./modules/servicenow-cr"

  servicenow_username               = var.servicenow_username
  servicenow_password               = var.servicenow_password
  automation_ci_name                = var.automation_ci_name
  automation_ci_short_description  = var.automation_ci_short_description
  user_name                         = var.user_name
  location_name                     = var.location_name
  department_name                   = var.department_name
  group_name                        = var.group_name
  custom_field_value                = var.custom_field_value
}

### CR-Servicenow/outputs.tf
output "automation_ci_sys_id" {
  value       = module.servicenow_cr.automation_ci_sys_id
  description = "The sys_id of the created Automation CI."
}

output "automation_ci_number" {
  value       = module.servicenow_cr.automation_ci_number
  description = "The number of the created Automation CI."
}

### CR-Servicenow/providers.tf
terraform {
  required_version = ">= 1.9.8"

  required_providers {
    servicenow = {
      source  = "servicenow/servicenow"
      version = ">= 1.0.0"
    }
    google = {
      source  = "hashicorp/google"
      version = ">= 6.11.2"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 6.11.2"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.6"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3.4.5"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.3"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.12.1"
    }
    external = {
      source  = "hashicorp/external"
      version = ">= 2.3.4"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.3"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.5.2"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.6.0"
    }
    venafi = {
      source  = "Venafi/venafi"
      version = ">= 0.21.1"
    }
  }
}

### CR-Servicenow/terraform.tfvars
servicenow_instance_url     = "https://hsbcitidu.service-now.com/servicenow"
servicenow_username         = "jenkins_service_account"
servicenow_password         = "jenkins_password"
automation_ci_name          = "Terraform Managed Automation CI"
automation_ci_short_description = "Automation CI created by Terraform"
user_name                   = "example_user"
location_name               = "example_location"
department_name             = "example_department"
group_name                  = "example_group"
custom_field_value          = "custom value"

### CR-Servicenow/variables.tf
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
  type    = string
  default = "Terraform Managed Automation CI"
}

variable "automation_ci_short_description" {
  type    = string
  default = "Automation CI created by Terraform"
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

### CR-Servicenow/modules/servicenow-cr/main.tf
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

### CR-Servicenow/modules/servicenow-cr/output.tf
output "automation_ci_sys_id" {
  value       = servicenow_ci.automation_creation.sys_id
  description = "The sys_id of the created Automation CI."
}

output "automation_ci_number" {
  value       = servicenow_ci.automation_creation.number
  description = "The number of the created Automation CI."
}

### CR-Servicenow/modules/servicenow-cr/variables.tf
variable "automation_ci_name" {
  type = string
}

variable "automation_ci_short_description" {
  type = string
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
  default = ""
}

variable "servicenow_username" {
  type      = string
  sensitive = true
}

variable "servicenow_password" {
  type      = string
  sensitive = true
}

### Jenkinsfile (Jenkins pipeline)
@Library("jenkins-shared-library@master") _

def CR_MINION_URL_MAP = [
    'UAT' : 'https://cr-minion-uat.uk.hsbc/api/v3',
    'PROD': 'https://cr-minion.uk.hsbc/api/v3'
]

properties([
    parameters([
        choice(name: 'ENV', choices: ['PROD', 'UAT'], description: 'Environment for CR'),
        string(name: 'JIRA_TICKET_REF', description: 'JIRA Ticket for CR'),
        string(name: 'CR_MINION_APPLICATION', defaultValue: 'otp-generic-service-template', description: 'CR-Minion App'),
        text(name: 'BUSINESS_JUSTIFICATION', defaultValue: '', description: 'Business justification'),
        text(name: 'IMPLEMENTATION_PLAN', defaultValue: '', description: 'Steps for change'),
        text(name: 'BUSINESS_IMPACT', defaultValue: '', description: 'Impact description'),
        string(name: 'CR_START_DATETIME', description: 'Start time in GMT'),
        choice(name: 'TIME_ZONE', choices: ['GMT', 'Europe/London', 'Asia/Shanghai'], description: 'Time zone'),
        string(name: 'CR_DURATION', defaultValue: '60', description: 'Change duration'),
        password(name: 'CR_LOGIN_PASSWORD', defaultValue: '', description: 'Login password')
    ])
])

def ENV = params.ENV ?: 'PROD'
def CR_MINION_URL = CR_MINION_URL_MAP.get(ENV)
def CR_MINION_CREDENTIALS_PREFIX = "cr-minion-bearer-token-${ENV.toLowerCase()}-"

pipeline {
    agent any
    stages {
        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }
        stage('Terraform Plan') {
            steps {
                sh '''
                terraform plan \
                    -var="servicenow_username=${env.SERVICENOW_USERNAME}" \
                    -var="servicenow_password=${env.SERVICENOW_PASSWORD}" \
                    -var="automation_ci_name=Terraform Managed Automation CI" \
                    -var="automation_ci_short_description=Automation CI created by Terraform" \
                    -var="user_name=example_user" \
                    -var="location_name=example_location" \
                    -var="department_name=example_department" \
                    -var="group_name=example_group" \
                    -var="custom_field_value=custom value"
                '''
            }
        }
        stage('Terraform Apply') {
            steps {
                sh '''
                terraform apply -auto-approve \
                    -var="servicenow_username=${env.SERVICENOW_USERNAME}" \
                    -var="servicenow_password=${env.SERVICENOW_PASSWORD}" \
                    -var="automation_ci_name=Terraform Managed Automation CI" \
                    -var="automation_ci_short_description=Automation CI created by Terraform" \
                    -var="user_name=example_user" \
                    -var="location_name=example_location" \
                    -var="department_name=example_department" \
                    -var="group_name=example_group" \
                    -var="custom_field_value=custom value"
                '''
            }
        }
    }
    environment {
        SERVICENOW_USERNAME = credentials('jenkins-servicenow-username')
        SERVICENOW_PASSWORD = credentials('jenkins-servicenow-password')
    }
}
