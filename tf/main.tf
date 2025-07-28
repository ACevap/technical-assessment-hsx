locals {
  common_tags = {
    Environment = "prod"
    Project     = "TechnicalAssessment-HSX"
    Owner       = "Alex"
  }
}

resource "azurerm_resource_group" "hsx_rg" {
  name     = "rg-ta-hsx"
  location = "West Europe"

  tags = local.common_tags
}

resource "azurerm_virtual_network" "hsx_vnet" {
  name                = "vnet-ta-hsx"
  address_space       = ["10.0.0.0/26"]
  location            = azurerm_resource_group.hsx_rg.location
  resource_group_name = azurerm_resource_group.hsx_rg.name

  tags = local.common_tags
}

resource "azurerm_subnet" "hsx_vm_subnet" {
  name                 = "subnet-ta-hsx"
  resource_group_name  = azurerm_resource_group.hsx_rg.name
  virtual_network_name = azurerm_virtual_network.hsx_vnet.name
  address_prefixes     = ["10.0.0.0/27"]
}


resource "azurerm_linux_virtual_machine" "hsx_vm" {
  name                = "vm-ta-hsx"
  resource_group_name = azurerm_resource_group.hsx_rg.name
  location            = azurerm_resource_group.hsx_rg.location
  size                = "Standard_A2_v2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.hsx_vm_nic.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  tags = local.common_tags
}

resource "azurerm_network_interface" "hsx_vm_nic" {
  name                = "vm-nic-ta-hsx"
  location            = azurerm_resource_group.hsx_rg.location
  resource_group_name = azurerm_resource_group.hsx_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.hsx_vm_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.hsx_vm_public_ip.id
  }

  tags = local.common_tags
}

resource "azurerm_public_ip" "hsx_vm_public_ip" {
  name                = "vm-pip-ta-hsx"
  resource_group_name = azurerm_resource_group.hsx_rg.name
  location            = azurerm_resource_group.hsx_rg.location
  allocation_method   = "Static"

  tags = local.common_tags
}

resource "azurerm_network_security_group" "hsx_nsg" {
  name                = "nsg-ta-hsx"
  location            = azurerm_resource_group.hsx_rg.location
  resource_group_name = azurerm_resource_group.hsx_rg.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    destination_port_range     = "22"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    destination_port_range     = "80"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = local.common_tags
}

resource "azurerm_subnet_network_security_group_association" "hsx_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.hsx_vm_subnet.id
  network_security_group_id = azurerm_network_security_group.hsx_nsg.id
}