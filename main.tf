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
  security_group     = path.module.nsg.nsg_name.id
}

module "nsg" {
  source                          = "./modules/nsg"
  resource_group                  = var.resource_group
  location                        = var.location
  nsg_name                        = var.nsg_name
  rule_name                       = var.rule_name
  rule_priority                   = var.rule_priority
  rule_direction                  = var.rule_direction
  rule_access                     = var.rule_access
  rule_protocol                   = var.rule_protocol
  rule_source_port_range          = var.rule_source_port_range
  rule_destination_port_range     = var.rule_destination_port_range
  rule_source_address_prefix      = var.rule_source_address_prefix
  rule_destination_address_prefix = var.rule_destination_address_prefix
}

# module "vm" {

# }
