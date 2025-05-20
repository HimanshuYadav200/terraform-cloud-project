#####################################
# Variables
#####################################
variable "resource_group_name" { type = string }
variable "location"            { type = string }

variable "vnet_name"           { type = string }
variable "vnet_address_space"  { type = list(string) }

variable "private_subnet_names"    { type = list(string) }
variable "private_subnet_prefixes" { type = list(string) }

variable "public_subnet_names"    { type = list(string) }
variable "public_subnet_prefixes" { type = list(string) }

variable "vm_size"        { type = string }
variable "admin_username" { type = string }

variable "image_version"      { type = string }
variable "db_image_name"      { type = string }
variable "db_gallery_name"    { type = string }
variable "frontend_image_name"{ type = string }
variable "frontend_gallery_name"{ type = string }
variable "backend_image_name" { type = string }
variable "backend_gallery_name"{ type = string }

#####################################
# 0) Lookup existing Resource Group & VNet
#####################################
data "azurerm_resource_group" "existing" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "existing" {
  name                = var.vnet_name
  resource_group_name = data.azurerm_resource_group.existing.name
}

#####################################
# 0b) Shared Image Gallery Lookups
#####################################
data "azurerm_shared_image" "db" {
  name                = var.db_image_name
  gallery_name        = var.db_gallery_name
  resource_group_name = data.azurerm_resource_group.existing.name
}

data "azurerm_shared_image_version" "db_ver" {
  name                = var.image_version
  gallery_name        = data.azurerm_shared_image.db.gallery_name
  image_name          = data.azurerm_shared_image.db.name
  resource_group_name = data.azurerm_resource_group.existing.name
}

data "azurerm_shared_image" "frontend" {
  name                = var.frontend_image_name
  gallery_name        = var.frontend_gallery_name
  resource_group_name = data.azurerm_resource_group.existing.name
}

data "azurerm_shared_image_version" "frontend_ver" {
  name                = var.image_version
  gallery_name        = data.azurerm_shared_image.frontend.gallery_name
  image_name          = data.azurerm_shared_image.frontend.name
  resource_group_name = data.azurerm_resource_group.existing.name
}

data "azurerm_shared_image" "backend" {
  name                = var.backend_image_name
  gallery_name        = var.backend_gallery_name
  resource_group_name = data.azurerm_resource_group.existing.name
}

data "azurerm_shared_image_version" "backend_ver" {
  name                = var.image_version
  gallery_name        = data.azurerm_shared_image.backend.gallery_name
  image_name          = data.azurerm_shared_image.backend.name
  resource_group_name = data.azurerm_resource_group.existing.name
}

#####################################
# 1) Subnets
#####################################
resource "azurerm_subnet" "private_subnet_1" {
  name                 = var.private_subnet_names[0]
  resource_group_name  = data.azurerm_resource_group.existing.name
  virtual_network_name = data.azurerm_virtual_network.existing.name
  address_prefixes     = [var.private_subnet_prefixes[0]]
}
resource "azurerm_subnet" "private_subnet_2" {
  name                 = var.private_subnet_names[1]
  resource_group_name  = data.azurerm_resource_group.existing.name
  virtual_network_name = data.azurerm_virtual_network.existing.name
  address_prefixes     = [var.private_subnet_prefixes[1]]
}
resource "azurerm_subnet" "private_subnet_3" {
  name                 = var.private_subnet_names[2]
  resource_group_name  = data.azurerm_resource_group.existing.name
  virtual_network_name = data.azurerm_virtual_network.existing.name
  address_prefixes     = [var.private_subnet_prefixes[2]]
}

resource "azurerm_subnet" "public_subnet_1" {
  name                 = var.public_subnet_names[0]
  resource_group_name  = data.azurerm_resource_group.existing.name
  virtual_network_name = data.azurerm_virtual_network.existing.name
  address_prefixes     = [var.public_subnet_prefixes[0]]
}
resource "azurerm_subnet" "public_subnet_2" {
  name                 = var.public_subnet_names[1]
  resource_group_name  = data.azurerm_resource_group.existing.name
  virtual_network_name = data.azurerm_virtual_network.existing.name
  address_prefixes     = [var.public_subnet_prefixes[1]]
}
resource "azurerm_subnet" "public_subnet_3" {
  name                 = var.public_subnet_names[2]
  resource_group_name  = data.azurerm_resource_group.existing.name
  virtual_network_name = data.azurerm_virtual_network.existing.name
  address_prefixes     = [var.public_subnet_prefixes[2]]
}

#####################################
# 2) NAT Gateway & Public IP
#####################################
resource "azurerm_public_ip" "nat_pip" {
  name                = "chat-app-nat-pip-new"
  resource_group_name = data.azurerm_resource_group.existing.name
  location            = data.azurerm_resource_group.existing.location
  allocation_method   = "Static"
  zones               = ["1"]
}

resource "azurerm_nat_gateway" "nat" {
  name                    = "chat-app-nat-gateway-new"
  resource_group_name     = data.azurerm_resource_group.existing.name
  location                = data.azurerm_resource_group.existing.location
  idle_timeout_in_minutes = 10
  zones                   = ["1"]
}

resource "azurerm_nat_gateway_public_ip_association" "nat_assoc" {
  nat_gateway_id       = azurerm_nat_gateway.nat.id
  public_ip_address_id = azurerm_public_ip.nat_pip.id
}

resource "azurerm_subnet_nat_gateway_association" "private1_nat" {
  subnet_id      = azurerm_subnet.private_subnet_1.id
  nat_gateway_id = azurerm_nat_gateway.nat.id
}
resource "azurerm_subnet_nat_gateway_association" "private2_nat" {
  subnet_id      = azurerm_subnet.private_subnet_2.id
  nat_gateway_id = azurerm_nat_gateway.nat.id
}
resource "azurerm_subnet_nat_gateway_association" "private3_nat" {
  subnet_id      = azurerm_subnet.private_subnet_3.id
  nat_gateway_id = azurerm_nat_gateway.nat.id
}

#####################################
# 3) SSH Keys
#####################################
resource "tls_private_key" "db_key"      { algorithm = "RSA"; rsa_bits = 4096 }
resource "tls_private_key" "backend_key" { algorithm = "RSA"; rsa_bits = 4096 }
resource "tls_private_key" "frontend_key"{ algorithm = "RSA"; rsa_bits = 4096 }

resource "local_file" "db_pem"      { filename="terraform-db.pem";      file_permission="0400"; content=tls_private_key.db_key.private_key_pem }
resource "local_file" "backend_pem" { filename="terraform-backend.pem"; file_permission="0400"; content=tls_private_key.backend_key.private_key_pem }
resource "local_file" "frontend_pem"{ filename="terraform-frontend.pem";file_permission="0400"; content=tls_private_key.frontend_key.private_key_pem }

#####################################
# 4) Network Interfaces
#####################################
resource "azurerm_network_interface" "db_nic" {
  name                = "db-nic"
  resource_group_name = data.azurerm_resource_group.existing.name
  location            = data.azurerm_resource_group.existing.location
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.private_subnet_1.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_network_interface" "backend_nic" {
  name                = "backend-nic"
  resource_group_name = data.azurerm_resource_group.existing.name
  location            = data.azurerm_resource_group.existing.location
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.private_subnet_2.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_public_ip" "frontend_pip" {
  name                = "frontend-pip"
  resource_group_name = data.azurerm_resource_group.existing.name
  location            = data.azurerm_resource_group.existing.location
  allocation_method   = "Dynamic"
  sku                 = "Basic"
}
resource "azurerm_network_interface" "frontend_nic" {
  name                = "frontend-nic"
  resource_group_name = data.azurerm_resource_group.existing.name
  location            = data.azurerm_resource_group.existing.location
  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.public_subnet_1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.frontend_pip.id
  }
}

#####################################
# 5) Linux VMs from Shared Image Gallery
#####################################
resource "azurerm_linux_virtual_machine" "database_vm" {
  name                = "terraform-database-vm"
  resource_group_name = data.azurerm_resource_group.existing.name
  location            = data.azurerm_resource_group.existing.location
  size                = var.vm_size
  admin_username      = var.admin_username
  network_interface_ids = [azurerm_network_interface.db_nic.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.db_key.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "db-vm-osdisk"
  }

  source_image_id = data.azurerm_shared_image_version.db_ver.id

  disable_password_authentication = true
}

resource "azurerm_linux_virtual_machine" "backend_vm" {
  name                = "terraform-backend-vm"
  resource_group_name = data.azurerm_resource_group.existing.name
  location            = data.azurerm_resource_group.existing.location
  size                = var.vm_size
  admin_username      = var.admin_username
  network_interface_ids = [azurerm_network_interface.backend_nic.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.backend_key.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "backend-vm-osdisk"
  }

  source_image_id = data.azurerm_shared_image_version.backend_ver.id

  disable_password_authentication = true
}

resource "azurerm_linux_virtual_machine" "frontend_vm" {
  name                = "terraform-frontend-vm"
  resource_group_name = data.azurerm_resource_group.existing.name
  location            = data.azurerm_resource_group.existing.location
  size                = var.vm_size
  admin_username      = var.admin_username
  network_interface_ids = [azurerm_network_interface.frontend_nic.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.frontend_key.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "frontend-vm-osdisk"
  }

  source_image_id = data.azurerm_shared_image_version.frontend_ver.id

  disable_password_authentication = true
}

#####################################
# 6) NSGs & Associations
#####################################
resource "azurerm_network_security_group" "database_nsg" {
  name                = "database-nsg"
  resource_group_name = data.azurerm_resource_group.existing.name
  location            = data.azurerm_resource_group.existing.location

  security_rule {
    name                       = "AllowSSH"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                    = "AllowFromApp"
    priority                = 110
    direction               = "Inbound"
    access                  = "Allow"
    protocol                = "*"
    source_address_prefixes = [var.private_subnet_prefixes[1], var.public_subnet_prefixes[0]]
    source_port_range       = "*"
    destination_port_range  = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "AllowToApp"
    priority                   = 210
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefixes = [var.private_subnet_prefixes[1], var.public_subnet_prefixes[0]]
    destination_port_range     = "*"
  }
}
resource "azurerm_subnet_network_security_group_association" "db_assoc" {
  subnet_id                 = azurerm_subnet.private_subnet_1.id
  network_security_group_id = azurerm_network_security_group.database_nsg.id
}

resource "azurerm_network_security_group" "backend_nsg" {
  name                = "backend-nsg"
  resource_group_name = data.azurerm_resource_group.existing.name
  location            = data.azurerm_resource_group.existing.location

  security_rule {
    name                       = "AllowSSH"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                    = "AllowFromDB"
    priority                = 110
    direction               = "Inbound"
    access                  = "Allow"
    protocol                = "*"
    source_address_prefixes = [var.private_subnet_prefixes[0], var.public_subnet_prefixes[0]]
    source_port_range       = "*"
    destination_port_range  = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "AllowToDB"
    priority                   = 210
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefixes = [var.private_subnet_prefixes[0], var.public_subnet_prefixes[0]]
    destination_port_range     = "*"
  }
}
resource "azurerm_subnet_network_security_group_association" "backend_assoc" {
  subnet_id                 = azurerm_subnet.private_subnet_2.id
  network_security_group_id = azurerm_network_security_group.backend_nsg.id
}

resource "azurerm_network_security_group" "frontend_nsg" {
  name                = "frontend-nsg"
  resource_group_name = data.azurerm_resource_group.existing.name
  location            = data.azurerm_resource_group.existing.location

  security_rule {
    name                       = "AllowSSH"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "AllowWeb"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["80","443"]
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
  security_rule {
    name                    = "AllowFromBackEnd"
    priority                = 200
    direction               = "Inbound"
    access                  = "Allow"
    protocol                = "*"
    source_address_prefixes = [var.private_subnet_prefixes[0], var.private_subnet_prefixes[1]]
    source_port_range       = "*"
    destination_port_range  = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "AllowOutInternet"
    priority                   = 210
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "Internet"
    destination_port_range     = "*"
  }
}
resource "azurerm_subnet_network_security_group_association" "frontend_assoc" {
  subnet_id                 = azurerm_subnet.public_subnet_1.id
  network_security_group_id = azurerm_network_security_group.frontend_nsg.id
}
