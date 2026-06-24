resource "azurerm_resource_group" "rg-grp" {
  name     = var.resource_group
  location = var.location
}

module "network" {
  source             = "./modules/network"
  resource_group     = var.resource_group
  location           = var.location
  network_name       = var.network_name
  vnet_address_space = var.vnet_address_space
  subnet_web_name    = var.subnet_web_name
  subnet_app_name    = var.subnet_app_name
  subnet_data_name   = var.subnet_data_name
  prefix_web         = var.prefix_web
  prefix_app         = var.prefix_app
  prefix_data        = var.prefix_data
}

# module "nsg" {

# }

# module "vm" {

# }
