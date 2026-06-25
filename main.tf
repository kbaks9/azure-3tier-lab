resource "azurerm_resource_group" "rg-grp" {
  name     = var.resource_group
  location = var.location
}

module "network" {
  source             = "./modules/network"
  resource_group     = azurerm_resource_group.rg-grp.name
  location           = azurerm_resource_group.rg-grp.location
  network_name       = var.network_name
  vnet_address_space = var.vnet_address_space

  subnet_web_name  = var.subnet_web_name
  subnet_app_name  = var.subnet_app_name
  subnet_data_name = var.subnet_data_name

  prefix_web  = var.prefix_web
  prefix_app  = var.prefix_app
  prefix_data = var.prefix_data

  security_group_web  = module.nsg_web.nsg_id
  security_group_app  = module.nsg_app.nsg_id
  security_group_data = module.nsg_data.nsg_id
}

module "nsg_web" {
  source         = "./modules/nsg"
  resource_group = azurerm_resource_group.rg-grp.name
  location       = azurerm_resource_group.rg-grp.location

  nsg_name  = var.nsg_web_name
  subnet_id = module.network.subnet_web_id
  rules = [
    {
      name                       = "Allow_Admin_SSH"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = var.my_ip
      destination_address_prefix = "*"
    },

    {

      name                       = "Web_Allow_HTTP" # Web Subnet Allows HTTP
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "Internet"
      destination_address_prefix = "10.0.1.0/24"
    },

    {
      name                       = "Web_Allow_HTTPS" # Web Subnet Allows HTTPS
      priority                   = 120
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "Internet"
      destination_address_prefix = "10.0.1.0/24"
  }]
}

module "nsg_app" {
  source         = "./modules/nsg"
  resource_group = azurerm_resource_group.rg-grp.name
  location       = azurerm_resource_group.rg-grp.location
  nsg_name       = var.nsg_app_name
  subnet_id      = module.network.subnet_app_id
  rules = [
    {
      name                       = "Allow_Web_To_App" # For Web -> App subnet
      priority                   = 130
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "8080"
      source_address_prefix      = "10.0.1.0/24"
      destination_address_prefix = "10.0.2.0/24"
  }]
}

module "nsg_data" {
  source         = "./modules/nsg"
  resource_group = azurerm_resource_group.rg-grp.name
  location       = azurerm_resource_group.rg-grp.location
  nsg_name       = var.nsg_data_name
  subnet_id      = module.network.subnet_data_id
  rules = [
    {
      name                       = "Allow_App_To_Data" # Allow App traffic -> Data
      priority                   = 140
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "1433"
      source_address_prefix      = "10.0.2.0/24"
      destination_address_prefix = "10.0.3.0/24"
  }]
}

locals {
  ssh_public_key = file(pathexpand("~/.ssh/id_ed25519.pub"))
}

module "web_vms" {
  source         = "./modules/vm"
  resource_group = azurerm_resource_group.rg-grp.name
  location       = azurerm_resource_group.rg-grp.location

  for_each = {
    web01 = {
      create_public_ip = true
      admin_username   = "steve"
      admin_password   = var.web01_admin_password
      ssh_public_key   = local.ssh_public_key
    }

    web02 = {
      create_public_ip = true
      admin_username   = "tony"
      admin_password   = var.web02_admin_password
      ssh_public_key   = local.ssh_public_key
    }
  }

  nic_name         = "nic-${each.key}"
  vm_name          = "vm-${each.key}"
  subnet_id        = module.network.subnet_web_id
  create_public_ip = each.value.create_public_ip
  admin_username   = each.value.admin_username
  admin_password   = each.value.admin_password
  ssh_public_key   = each.value.ssh_public_key
}

module "app_vms" {
  source         = "./modules/vm"
  resource_group = azurerm_resource_group.rg-grp.name
  location       = azurerm_resource_group.rg-grp.location

  for_each = toset(["app01", "app02"])

  nic_name  = "nic-${each.key}"
  vm_name   = "vm-${each.key}"
  subnet_id = module.network.subnet_app_id

  create_public_ip = false
  admin_username   = "azureadmin"
  ssh_public_key   = local.ssh_public_key
}

module "data_vms" {
  source         = "./modules/vm"
  resource_group = azurerm_resource_group.rg-grp.name
  location       = azurerm_resource_group.rg-grp.location

  for_each = toset(["data01", "data02"])

  nic_name  = "nic-${each.key}"
  vm_name   = "vm-${each.key}"
  subnet_id = module.network.subnet_data_id

  create_public_ip = false
  admin_username   = "azureadmin"
  ssh_public_key   = local.ssh_public_key
}
