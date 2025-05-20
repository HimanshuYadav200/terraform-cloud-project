variable "resource_group_name" {
  description = "name of rg"
  type        = string
}

variable "location" {
  description = "location to deploy resources"
  type        = string
}

variable "vnet_name" {
  description = "name of vnet"
  type        = string
}

variable "vnet_address_space" {
  description = "address space of vnet"
  type        = list(string)
}

variable "private_subnet_names" {
  description = "private subnet names"
  type        = list(string)
}

variable "private_subnet_prefixes" {
  description = "private subnet addresses"
  type        = list(string)
}

variable "public_subnet_names" {
  description = "public subnet names"
  type        = list(string)
}

variable "public_subnet_prefixes" {
  description = "public subnet addresses"
  type        = list(string)
}

variable "vm_name" {
  description = "Name of the virtual machine"
  type        = string
  default     = "test"
}

variable "admin_username" {
  description = "root username"
  type        = string
  default     = "azureuser"
}

variable "vm_size" {
  description = "size of vm"
  type        = string
  default     = "Standard_B1s"
}

variable "image_publisher" {
  description = "publisher details"
  type        = string
  default     = "Canonical"
}

variable "image_offer" {
  description = "offer details"
  type        = string
  default     = "0001-com-ubuntu-server-jammy"
}

variable "image_sku" {
  description = "sku details of image"
  type        = string
  default     = "22_04-lts"
}

variable "image_version" {
  description = "version of image"
  type        = string
  default     = "latest"
}

variable "private_subnet_1_prefix" {
  description = "database nsg"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_2_prefix" {
  description = "backend nsg"
  type        = string
  default     = "10.0.2.0/24"
}

variable "public_subnet_1_prefix" {
  description = "fronntend nsg"
  type        = string
  default     = "10.0.3.0/24"
}