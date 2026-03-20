resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                            = "vmss-app"
  resource_group_name             = var.rg_name
  location                        = var.location
  sku                             = "Standard_B2s"
  instances                       = 2
  admin_username                  = var.admin_user
  admin_password                  = var.admin_password
  disable_password_authentication = false

  custom_data = filebase64("${path.root}/cloud-init.yaml")

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "nic-vmss"
    primary = true

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = var.app_subnet_id
      application_gateway_backend_address_pool_ids = var.backend_pool_ids
    }
  }
}