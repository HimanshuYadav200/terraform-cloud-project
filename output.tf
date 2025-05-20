output "workspace_name" {
  description = "The current Terraform workspace"
  value       = terraform.workspace
}

output "resource_group_name" {
  description = "The name of the resource group created"
  value       = azurerm_resource_group.main.name
}

output "vnet_details" {
  description = "Details of the virtual network"
  value = {
    name          = azurerm_virtual_network.main.name
    address_space = azurerm_virtual_network.main.address_space
    location      = azurerm_virtual_network.main.location
  }
}

output "subnet_details" {
  description = "Details of the subnet"
  value = {
    name            = azurerm_subnet.main.name
    address_prefix  = azurerm_subnet.main.address_prefixes[0]
  }
}

output "vm_info" {
  description = "Information about the Linux VM"
  value = {
    name         = azurerm_linux_virtual_machine.vm.name
    location     = azurerm_linux_virtual_machine.vm.location
    private_ip   = azurerm_network_interface.vm_nic.ip_configuration[0].private_ip_address
    username     = azurerm_linux_virtual_machine.vm.admin_username
  }
}
