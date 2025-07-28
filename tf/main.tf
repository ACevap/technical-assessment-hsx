resource "azurerm_resource_group" "hsx-rg" {
  name     = "rg-ta-hsx"
  location = "West Europe"
}

resource "azurerm_virtual_network" "hsx-vnet" {
  name                = "vnet-ta-hsx"
  address_space       = ["10.0.0.0/26"]
  location            = azurerm_resource_group.hsx-rg.location
  resource_group_name = azurerm_resource_group.hsx-rg.name
}

resource "azurerm_subnet" "hsx-vm-subnet" {
  name                 = "subnet-ta-hsx"
  resource_group_name  = azurerm_resource_group.hsx-rg.name
  virtual_network_name = azurerm_virtual_network.hsx-vnet.name
  address_prefixes     = ["10.0.0.0/27"]
}