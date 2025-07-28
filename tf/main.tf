resource "azurerm_resource_group" "hsx-rg" {
  name     = "rg-ta-hsx"
  location = "West Europe"

  tags = {
    Environment = "Production"
    Project = "TechnicalAssessment-HSX"
    Owner       = "Alex"
  }
}

resource "azurerm_virtual_network" "hsx-vnet" {
  name                = "vnet-ta-hsx"
  address_space       = ["10.0.0.0/26"]
  location            = azurerm_resource_group.hsx-rg.location
  resource_group_name = azurerm_resource_group.hsx-rg.name

  tags = {
    Environment = "Production"
    Project = "TechnicalAssessment-HSX"
    Owner       = "Alex"
  }
}

resource "azurerm_subnet" "hsx-vm-subnet" {
  name                 = "subnet-ta-hsx"
  resource_group_name  = azurerm_resource_group.hsx-rg.name
  virtual_network_name = azurerm_virtual_network.hsx-vnet.name
  address_prefixes     = ["10.0.0.0/27"]
}


resource "azurerm_linux_virtual_machine" "hsx-vm" {
  name                = "vm-ta-hsx"
  resource_group_name = azurerm_resource_group.hsx-rg.name
  location            = azurerm_resource_group.hsx-rg.location
  size                = "Standard_A2_v2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.hsx-vm-nic.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
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

  tags = {
    Environment = "Production"
    Project = "TechnicalAssessment-HSX"
    Owner       = "Alex"
  }
}

resource "azurerm_network_interface" "hsx-vm-nic" {
  name                = "vm-nic-ta-hsx"
  location            = azurerm_resource_group.hsx-rg.location
  resource_group_name = azurerm_resource_group.hsx-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.hsx-vm-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.hsx-vm-public-ip.id
  }

  tags = {
    Environment = "Production"
    Project = "TechnicalAssessment-HSX"
    Owner       = "Alex"
  }
}

resource "azurerm_public_ip" "hsx-vm-public-ip" {
  name                = "vm-pip-ta-hsx"
  resource_group_name = azurerm_resource_group.hsx-rg.name
  location            = azurerm_resource_group.hsx-rg.location
  allocation_method   = "Static"

  tags = {
    Environment = "Production"
    Project = "TechnicalAssessment-HSX"
    Owner       = "Alex"
  }
}