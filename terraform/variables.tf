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
  validation {
    condition     = can(regex("^[a-z_][a-z0-9_-]{0,31}$", var.admin_username))
    error_message = "Use a Linux username of at most 32 lowercase letters, digits, underscores or hyphens, beginning with a letter or underscore."
  }
}

variable "ssh_public_key_path" {
  type = string
}
variable "subscription_id" {
  description = "Azure subscription in which to create resources."
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "Administrator public IPv4 CIDR allowed to SSH, usually a single /32."
  type        = string
  validation {
    condition     = can(cidrnetmask(var.ssh_allowed_cidr)) && !endswith(var.ssh_allowed_cidr, "/0")
    error_message = "Provide a valid IPv4 CIDR narrower than /0."
  }
}
