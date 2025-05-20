resource "azurerm_resource_group" "main" {
  name     = "rg-${terraform.workspace}"
  location = var.location

  tags = {
    Environment = terraform.workspace
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_virtual_network" "main" {
  name                = "vnet-${terraform.workspace}"
  address_space       = ["10.${terraform.workspace == "dev" ? 1 : terraform.workspace == "test" ? 2 : 3}.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    Environment = terraform.workspace
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_subnet" "main" {
  name                 = "subnet-${terraform.workspace}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.${terraform.workspace == "dev" ? 1 : terraform.workspace == "test" ? 2 : 3}.0.0/24"]
}

resource "tls_private_key" "vm_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "vm_private_key_pem" {
  content         = tls_private_key.vm_ssh_key.private_key_pem
  filename        = "${path.module}/terraform-${terraform.workspace}-vm.pem"
  file_permission = "0400"
}

resource "azurerm_network_interface" "vm_nic" {
  name                = "nic-${terraform.workspace}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_public_ip.id
  }

  tags = {
    Environment = terraform.workspace
    ManagedBy   = "Terraform"
  }
}


resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "vm-${terraform.workspace}"
  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  size                  = "Standard_B1s"
  admin_username        = "azureuser"
  network_interface_ids = [azurerm_network_interface.vm_nic.id]

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.vm_ssh_key.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "osdisk-${terraform.workspace}"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  tags = {
    Environment = terraform.workspace
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_public_ip" "vm_public_ip" {
  name                = "public-ip-${terraform.workspace}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Dynamic"
  sku                 = "Basic"

  tags = {
    Environment = terraform.workspace
    ManagedBy   = "Terraform"
  }
}

