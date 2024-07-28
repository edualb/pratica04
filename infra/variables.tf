variable "resource_group_location" {
  type        = string
  default     = "eastus"
  description = "Local do grupo de recursos."
}

variable "resource_group_name" {
  type        = string
  default     = "student-rg"
  description = "Nome do grupo de recursos."
}

variable "username" {
  type        = string
  default     = "azureuser"
  description = "O usuario que vai ser usado para acessar a VM."
}

variable "VM_ADMIN_PASSWORD" {
  type        = string
  description = "A senha do usuario que vai ser usado para acessar a VM."
}