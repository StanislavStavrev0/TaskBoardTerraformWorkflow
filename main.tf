terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.25.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "b9e412f3-4340-40aa-93bb-ee66bd68a9b6"

  features {

  }
}

resource "random_integer" "random" {
  min = 10000
  max = 90000
}

resource "azurerm_resource_group" "ssrg" {
  name     = "${var.resource_group_name}-${random_integer.random.result}"
  location = var.resource_group_location
}

resource "azurerm_service_plan" "asp" {
  name                = "${var.app_service_plan}-${random_integer.random.result}"
  resource_group_name = azurerm_resource_group.ssrg.name
  location            = azurerm_resource_group.ssrg.location
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_linux_web_app" "alwa" {
  name                = "${var.app_service_name}-${random_integer.random.result}"
  resource_group_name = azurerm_resource_group.ssrg.name
  location            = azurerm_resource_group.ssrg.location
  service_plan_id     = azurerm_service_plan.asp.id

  site_config {
    application_stack {
      dotnet_version = "6.0"
    }
    always_on = false
  }
  connection_string {
    name  = "DefaultConnection"
    type  = "SQLAzure"
    value = "Data Source=tcp:${azurerm_mssql_server.sqlserver.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.database.name};User ID=${azurerm_mssql_server.sqlserver.administrator_login};Password=${azurerm_mssql_server.sqlserver.administrator_login_password};Trusted_Connection=False; MultipleActiveResultSets=True;"
  }
}
resource "azurerm_mssql_server" "sqlserver" {
  name                         = "${var.sql_server_name}-${random_integer.random.result}"
  resource_group_name          = azurerm_resource_group.ssrg.name
  location                     = azurerm_resource_group.ssrg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password
  minimum_tls_version          = "1.2"

}

resource "azurerm_mssql_database" "database" {
  name                 = "${var.sql_database_name}-${random_integer.random.result}"
  server_id            = azurerm_mssql_server.sqlserver.id
  collation            = "SQL_Latin1_General_CP1_CI_AS"
  license_type         = "LicenseIncluded"
  max_size_gb          = 2
  sku_name             = "S0"
  zone_redundant       = false
  storage_account_type = "Zone"
  geo_backup_enabled   = false
}

resource "azurerm_mssql_firewall_rule" "firewall" {
  name             = "${var.firewall_rule_name}-${random_integer.random.result}"
  server_id        = azurerm_mssql_server.sqlserver.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_app_service_source_control" "asc" {
  app_id                 = azurerm_linux_web_app.alwa.id
  repo_url               = var.repo_url
  branch                 = "main"
  use_manual_integration = true
}