variable "project_name" {
  type    = string
  default = "practice-management"
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "location" {
  type    = string
  default = "Central India"
}

variable "vm_size" {
  type    = string
  default = "Standard_B2s"
}

variable "admin_username" {
  type    = string
  default = "azureadmin"
}

variable "ssh_public_key_path" {
  type = string
}