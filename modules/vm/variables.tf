variable "resource_group" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure location where the resource exists"
}

variable "nic_name" {
  type        = string
  description = "The name of the network interface."
}

variable "subnet_id" {
  type = string
}

variable "vm_name" {
  type = string
}

variable "create_public_ip" {
  type        = string
  description = "Create public IP address"
}

variable "admin_username" {
  type        = string
  description = "The admin username for SSH access"
}

variable "admin_password" {
  type        = string
  description = "The admin password for SSH access"
  sensitive   = true
  default     = null
}

variable "ssh_public_key" {
  type    = string
  default = null
}
