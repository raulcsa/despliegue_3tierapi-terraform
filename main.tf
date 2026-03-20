# main.tf (Raíz)

locals {
  rg_name  = "rg-3tier-produccion"
  location = "norwayeast"
}

module "network" {
  source   = "./modules/network"
  rg_name  = local.rg_name
  location = local.location
}

module "load_balancer" {
  source        = "./modules/load_balancer"
  rg_name       = local.rg_name
  location      = local.location
  web_subnet_id = module.network.web_subnet_id
}

module "compute" {
  source           = "./modules/compute"
  rg_name          = local.rg_name
  location         = local.location
  app_subnet_id    = module.network.app_subnet_id
  backend_pool_ids = [module.load_balancer.backend_pool_id]
  admin_user       = "azureadmin"
  admin_password   = var.admin_password
}

module "database" {
  source       = "./modules/database"
  rg_name      = local.rg_name
  location     = local.location
  db_subnet_id = module.network.db_subnet_id
  db_admin     = "sqladmin"
  db_password  = var.db_password 
}

output "application_url" {
  value       = "http://${module.load_balancer.public_ip}"
  description = "URL pública para acceder a la aplicación"
}
