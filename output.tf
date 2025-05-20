# output "resource_group_name" {
#   description = "name of the rg"
#   value       = azurerm_resource_group.resource_group_name
# }

# output "resource_group_location" {
#   description = "location of rg"
#   value       = azurerm_resource_group.resource_group_name.location
# }

# resource "azurerm_virtual_network" "chat_app_vnet" {
#   name                = var.vnet_name
#   address_space       = var.vnet_address_space
#   location            = azurerm_resource_group.resource_group_name.location
#   resource_group_name = azurerm_resource_group.resource_group_name.name
# }

# output "vnet_name" {
#   description = "name of vnet"
#   value       = azurerm_virtual_network.chat_app_vnet.name
# }

# output "vnet_address_space" {
#   description = "address space of vnet"
#   value       = azurerm_virtual_network.chat_app_vnet.address_space
# }

# output "private_subnet_address_prefixes" {
#   description = "address range of private subnet"
#   value = [
#     azurerm_subnet.private_subnet_1.address_prefixes[0],
#     azurerm_subnet.private_subnet_2.address_prefixes[0],
#     azurerm_subnet.private_subnet_3.address_prefixes[0]
#   ]
# }

# output "public_subnet_address_prefixes" {
#   description = "address range of public subnet"
#   value = [
#     azurerm_subnet.public_subnet_1.address_prefixes[0],
#     azurerm_subnet.public_subnet_2.address_prefixes[0],
#     azurerm_subnet.public_subnet_3.address_prefixes[0]
#   ]
# }

# output "nat_gateway_public_ip" {
#   description = "public ip of NAT"
#   value       = azurerm_public_ip.nat_public_ip.ip_address
# }

# output "database_vm_private_ip" {
#   value       = azurerm_network_interface.database_vm_nic.private_ip_address
#   description = "private IP of db vm"
# }

# output "backend_vm_private_ip" {
#   value       = azurerm_network_interface.backend_vm_nic.private_ip_address
#   description = "private IP of the backend vm"
# }

# output "frontend_vm_private_ip" {
#   value       = azurerm_network_interface.frontend_vm_nic.private_ip_address
#   description = "private IP of the frontend vm"
# }

# output "database_nsg_name" {
#   value = azurerm_network_security_group.database_nsg.name
# }

# output "backend_nsg_name" {
#   value = azurerm_network_security_group.backend_nsg.name
# }

# output "frontend_nsg_name" {
#   value = azurerm_network_security_group.frontend_nsg.name
# }


