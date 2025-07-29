variable "ssh_public_key" {
  type = string
  description = "The SSH public key to access the VM"
}

variable "location" {
  description = "Azure Region to deploy resources"
  type = string
  default = "West Europe"
}

variable "project_name" {
  description = "The name prefix for all resources"
  type = string
  default = "ta-hsx"
}

variable "admin_username" {
  description = "VM Admin username"
  type = string
  default = "adminuser"
}

variable "vm_size" {
  description = "VM Size"
  type = string
  default = "Standard_A2_v2"
}

variable "vnet_address_space" {
  description = "CIDR block for the VNET"
  type = list(string)
  default = ["10.0.0.0/26"]
}

variable "subnet_address_space" {
  description = "CIDR block for the VM subnet"
  type = list(string)
  default = ["10.0.0.0/27"]
}