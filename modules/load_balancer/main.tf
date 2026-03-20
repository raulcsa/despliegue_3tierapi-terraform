resource "azurerm_public_ip" "pip" {
  name                = "pip-appgw"
  resource_group_name = var.rg_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "appgw" {
  name                = "appgw-3tier"
  resource_group_name = var.rg_name
  location            = var.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = var.web_subnet_id
  }

  frontend_port {
    name = "fe-port"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "fe-ip-config"
    public_ip_address_id = azurerm_public_ip.pip.id
  }

  backend_address_pool {
    name = "be-pool"
  }

  backend_http_settings {
    name                  = "be-htst"
    cookie_based_affinity = "Disabled"
    port                  = 8080
    protocol              = "Http"
    request_timeout       = 20
  }

  http_listener {
    name                           = "listener"
    frontend_ip_configuration_name = "fe-ip-config"
    frontend_port_name             = "fe-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "listener"
    backend_address_pool_name  = "be-pool"
    backend_http_settings_name = "be-htst"
    priority                   = 100
  }
}