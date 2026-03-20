variable "rg_name" { type = string }
variable "location" { type = string }
variable "app_subnet_id" { type = string }
variable "backend_pool_ids" { type = list(string) }
variable "admin_user" { type = string }
variable "admin_password" { type = string }