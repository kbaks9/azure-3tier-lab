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
  security_group     = module.nsg.nsg_id
}

module "nsg" {
  source         = "./modules/nsg"
  resource_group = azurerm_resource_group.rg-grp.name
  location       = azurerm_resource_group.rg-grp.location
  nsg_web_name   = var.nsg_web_name
  nsg_app_name   = var.nsg_app_name
  nsg_data_name  = var.nsg_data_name
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
    },

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

    },

    {
      name                       = "Allow_App_To_Data"
      priority                   = 140
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "1433"
      source_address_prefix      = "10.0.2.0/24"
      destination_address_prefix = "10.0.3.0/24"
  }]


  depends_on = [
    azurerm_resource_group.rg-grp
  ]
}

# module "vm" {

# }
