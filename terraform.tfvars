resource_group_name = "chat-app-terraform"
location            = "East US"

vnet_name          = "chat-app-network-terraform"
vnet_address_space = ["10.0.0.0/16"]

private_subnet_names    = ["private-subnet-1", "private-subnet-2", "private-subnet-3"]
private_subnet_prefixes = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

public_subnet_names    = ["public-subnet-1", "public-subnet-2", "public-subnet-3"]
public_subnet_prefixes = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

admin_username = "azureuser"
vm_size        = "Standard_B1s"

image_publisher = "Canonical"
image_offer     = "0001-com-ubuntu-server-jammy"
image_sku       = "22_04-lts"
image_version   = "latest"