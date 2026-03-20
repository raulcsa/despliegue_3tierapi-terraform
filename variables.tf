variable "admin_password" {
  type        = string
  description = "Contraseña del administrador para las máquinas virtuales"
  sensitive   = true
}

variable "db_password" {
  type        = string
  description = "Contraseña del administrador para la base de datos SQL"
  sensitive   = true
}
