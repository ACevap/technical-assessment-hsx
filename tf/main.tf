locals {
  common_tags = {
    Environment = "prod"
    Project     = "TechnicalAssessment-HSX"
    Owner       = "Alex"
  }
}

resource "azurerm_resource_group" "hsx_rg" {
  name     = "rg-${var.project_name}"
  location = var.location

  tags = local.common_tags
}

resource "azurerm_virtual_network" "hsx_vnet" {
  name                = "vnet-${var.project_name}"
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.hsx_rg.location
  resource_group_name = azurerm_resource_group.hsx_rg.name

  tags = local.common_tags
}

resource "azurerm_subnet" "hsx_vm_subnet" {
  name                 = "subnet-${var.project_name}"
  resource_group_name  = azurerm_resource_group.hsx_rg.name
  virtual_network_name = azurerm_virtual_network.hsx_vnet.name
  address_prefixes     = var.subnet_address_space
}


resource "azurerm_linux_virtual_machine" "hsx_vm" {
  name                = "vm-${var.project_name}"
  resource_group_name = azurerm_resource_group.hsx_rg.name
  location            = azurerm_resource_group.hsx_rg.location
  size                = var.vm_size
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.hsx_vm_nic.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
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
  name                = "vm-nic-${var.project_name}"
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
  name                = "vm-pip-${var.project_name}"
  resource_group_name = azurerm_resource_group.hsx_rg.name
  location            = azurerm_resource_group.hsx_rg.location
  allocation_method   = "Static"

  tags = local.common_tags
}

resource "azurerm_network_security_group" "hsx_nsg" {
  name                = "nsg-${var.project_name}"
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