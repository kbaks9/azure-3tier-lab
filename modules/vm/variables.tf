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
