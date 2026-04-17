terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }
}


provider "azurerm" {
  features {}
  subscription_id = "3556e95d-01ce-4530-a696-7b54261a79c2"
}


resource "azurerm_resource_group" "rg" {
  name     = "watchlistRG"
  location = "Poland Central"
}


resource "azurerm_service_plan" "asp" {
  name                = "watchlist-service-plan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "F1"
}



resource "azurerm_mssql_server" "mssql_server" {
  name                         = var.mssqlserver_name
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = var.admin_login
  administrator_login_password = var.admin_pass
  minimum_tls_version          = "1.2"
}

resource "azurerm_mssql_database" "mssql_db" {
  name                 = var.mssqldb_name
  server_id            = azurerm_mssql_server.mssql_server.id
  collation            = "SQL_Latin1_General_CP1_CI_AS"
  license_type         = "LicenseIncluded"
  max_size_gb          = 2
  sku_name             = "Basic"
  zone_redundant       = false
  storage_account_type = "Local"

  lifecycle {
    prevent_destroy = true
  }

}

resource "azurerm_mssql_firewall_rule" "firewall_rule" {
  name             = var.firewall_rule_name
  server_id        = azurerm_mssql_server.mssql_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}


resource "azurerm_linux_web_app" "alwa" {
  name                = var.linux_web_app_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.asp.id

  site_config {
    always_on = false

    application_stack {
      dotnet_version = "6.0"
    }
  }

  connection_string {
    name  = "DefaultConnection"
    type  = "SQLAzure"
    value = "Data Source=tcp:${azurerm_mssql_server.mssql_server.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.mssql_db.name};User ID=${azurerm_mssql_server.mssql_server.administrator_login};Password=${azurerm_mssql_server.mssql_server.administrator_login_password};Trusted_Connection=False;MultipleActiveResultSets=True;"
  }
}





resource "azurerm_app_service_source_control" "source_control" {
  app_id   = azurerm_linux_web_app.alwa.id
  branch   = var.github-repo-main-branch
  repo_url = var.github-repo-url

  use_manual_integration = true
}


