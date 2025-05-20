resource "azurerm_resource_group" "rg_import_infra" {
  name     = "rg-import-infra"
  location = "East US"
}

resource "azurerm_virtual_network" "imported_vnet" {
  name                = "vnet-import-infra"
  resource_group_name = azurerm_resource_group.rg_import_infra.name
  location            = azurerm_resource_group.rg_import_infra.location
  address_space       = ["10.0.0.0/16"]
}

# Public subnet
resource "azurerm_subnet" "public1" {
  name                 = "Public-subnet1"
  resource_group_name  = azurerm_resource_group.rg_import_infra.name
  virtual_network_name = azurerm_virtual_network.imported_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Private subnet
resource "azurerm_subnet" "private1" {
  name                 = "Private-subnet1"
  resource_group_name  = azurerm_resource_group.rg_import_infra.name
  virtual_network_name = azurerm_virtual_network.imported_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

// 1) Network Interface for your VM
resource "azurerm_network_interface" "import_vm_nic" {
  name                = "import-vm559_z3"
  resource_group_name = azurerm_resource_group.rg_import_infra.name
  location            = azurerm_resource_group.rg_import_infra.location

  ip_configuration {
    name                          = "ipconfig1"          # <-- match existing
    subnet_id                     = azurerm_subnet.public1.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.2.4"
    public_ip_address_id          = "/subscriptions/af712bef-9eba-4343-a2ad-74866bbc96c7/resourceGroups/rg-import-infra/providers/Microsoft.Network/publicIPAddresses/import-vm559_z3-ip"  # if you want to manage the public IP too
  }
}


// 2) The Ubuntu VM itself
resource "azurerm_linux_virtual_machine" "import_vm" {
  name                  = "import-vm"
  resource_group_name   = azurerm_resource_group.rg_import_infra.name
  location              = azurerm_resource_group.rg_import_infra.location
  size                  = "Standard_D2s_v3"
  

  network_interface_ids = [
    azurerm_network_interface.import_vm_nic.id,
  ]

  os_disk {
    name              = "import-vm_disk1_931fdb1fbb794b77b8a6aa340dbb53cf"
    caching           = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "24_04-lts"
    version   = "latest"
  }



  admin_username = "azureuser"
  disable_password_authentication = true

   admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.linux_key.public_key_openssh
  }

}

resource "azurerm_public_ip" "import_vm_pip" {
  name                = "import-vm559_z3-ip"
  resource_group_name = azurerm_resource_group.rg_import_infra.name
  location            = azurerm_resource_group.rg_import_infra.location
  allocation_method   = "Static"
}
