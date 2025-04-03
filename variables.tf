variable "resource_group_name" {
  type        = string
  description = "the name of the RG"
}

variable "resource_group_location" {
  type        = string
  description = "the location of the RG"
}

variable "app_service_plan" {
  type        = string
  description = "the name of the Service Plan"
}

variable "app_service_name" {
  type        = string
  description = "the name of the App"
}

variable "sql_server_name" {
  type        = string
  description = "the name of the SQL server"
}

variable "sql_database_name" {
  type        = string
  description = "the name of the SQL DB"
}

variable "sql_admin_login" {
  type        = string
  description = "the admin login"
}

variable "sql_admin_password" {
  type        = string
  description = "the admin password"
}

variable "firewall_rule_name" {
  type        = string
  description = "the name of the firewall"
}

variable "repo_url" {
  type        = string
  description = "the location the repository URL"
}