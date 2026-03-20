# Despliegue de Arquitectura de 3 Capas en Azure con Terraform

Este proyecto contiene la Infraestructura como Código (IaC) necesaria para desplegar una arquitectura clásica de 3 capas en Microsoft Azure, garantizando alta disponibilidad, seguridad de red y automatización en la configuración de los servidores.



## Descripción de la Arquitectura

El despliegue está modularizado y se divide en las siguientes capas lógicas:

1. **Capa de Red (Network):** Crea una Virtual Network (VNet) fragmentada en tres subredes aisladas (Web, App, DB). Implementa un Grupo de Seguridad de Red (NSG) que actúa como firewall, permitiendo que las máquinas virtuales solo reciban tráfico proveniente del balanceador de carga.
2. **Capa Web (Load Balancer):** Implementa un Azure Application Gateway (Standard_v2) con una IP Pública. Se encarga de recibir el tráfico HTTP de internet, aplicar políticas de seguridad TLS modernas y balancear la carga hacia los servidores internos.
3. **Capa de Aplicación (Compute):** Utiliza un Virtual Machine Scale Set (VMSS) con Ubuntu 22.04. Mediante un script `cloud-init`, instala las dependencias de Python, crea un entorno virtual y levanta una API en Flask gestionada como un servicio nativo de Linux (`systemd`) en el puerto 8080.
4. **Capa de Datos (Database):** Despliega un servidor lógico de Azure SQL y una base de datos. Se configura con acceso público deshabilitado y se conecta directamente a la subred interna mediante un Private Endpoint, garantizando que el tráfico de datos nunca salga a internet.

## Requisitos Previos

* Tener instalado **Terraform** (versión 1.0 o superior).
* Tener instalada la **Azure CLI**.
* Haber iniciado sesión en la suscripción de Azure ejecutando `az login` en la terminal.
* Crear una storage account en azure y un blob container para guardar el estado de terraform (tambien se puede hacer desde local pero habría que modificar el providers.tf)

## Estructura del Proyecto

```text
3-tier-api/
├── modules/
│   ├── network/          # Definición de VNet, Subredes y NSG
│   ├── load_balancer/    # IP Pública y Application Gateway
│   ├── compute/          # Virtual Machine Scale Set y discos
│   └── database/         # Azure SQL Server, Database y Private Endpoint
├── providers.tf          # Configuración del proveedor azurerm
├── main.tf               # Orquestador principal de los módulos
├── variables.tf          # Declaración de variables sensibles
├── cloud-init.yaml       # Configuración de arranque de las VMs (Flask + Systemd)
└── .gitignore            # Exclusión de archivos de estado y secretos# 3TIER-WEB
```
# Instrucciones de Despliegue
Abrir el terminal en el directorio raíz del proyecto y ejecuta los siguientes comandos en orden:

## 1. Inicializar el entorno
Descarga los plugins del proveedor de Azure y prepara el directorio de trabajo.
```
terraform init
```
## 2. Planificar la infraestructura
Verifica los recursos que Terraform va a crear en tu cuenta de Azure.
```
terraform plan -var-file="secretos.tfvars"
```

Puedes crear tu propio fichero secretos.tfvars como:
```
admin_password = "contraseña"
db_password    = "contraseña"
```
También puedes no crearlo y al momento de ejecutar terraform plan te pedirá las claves por el terminalc


## 3. Aplicar el despliegue
Ejecuta la creación de la infraestructura. 
```
terraform apply -var-file="secretos.tfvars"
```
El proceso tardará varios minutos. Al finalizar, Terraform imprimirá en la consola una variable de salida (application_url) con la dirección IP pública del Application Gateway.

## 4. Limpieza de Recursos
Para evitar costes continuos en la suscripción de Azure (especialmente por el Application Gateway y la base de datos SQL), hay que asegurarse de destruir toda la infraestructura una vez que hayas terminado tus pruebas:
```
terraform destroy -var-file="secretos.tfvars"
```

