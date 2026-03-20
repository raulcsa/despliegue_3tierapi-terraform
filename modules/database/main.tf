resource "azurerm_mssql_server" "sql" {
  name                          = "sqlserver-3tier-${random_integer.suffix.result}"
  resource_group_name           = var.rg_name
  location                      = var.location
  version                       = "12.0"
  administrator_login           = var.db_admin
  administrator_login_password  = var.db_password
  public_network_access_enabled = false
}

resource "random_integer" "suffix" {
  min = 1000
  max = 9999
}

resource "azurerm_mssql_database" "db" {
  name      = "appdb"
  server_id = azurerm_mssql_server.sql.id
  sku_name  = "S0"
}

resource "azurerm_private_endpoint" "pe" {
  name                = "pe-sql"
  location            = var.location
  resource_group_name = var.rg_name
  subnet_id           = var.db_subnet_id

  private_service_connection {
    name                           = "psc-sql"
    private_connection_resource_id = azurerm_mssql_server.sql.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }
}