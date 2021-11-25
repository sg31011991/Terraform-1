
 resource "azurerm_resource_group" "rg" {
   name     = "TFRDemo"
   location = "westus"
 }
  resource "azurerm_virtual_network" "rg" {
   name                = "rg-network"
   address_space       = ["10.0.0.0/16"]
   location            = azurerm_resource_group.rg.location
   resource_group_name = azurerm_resource_group.rg.name
 }
 resource "azurerm_subnet" "rg" {
   name                 = "internal"
   resource_group_name  = azurerm_resource_group.rg.name
   virtual_network_name = azurerm_virtual_network.rg.name
   address_prefixes     = ["10.0.2.0/24"]
 }
 resource "azurerm_public_ip" "publicip" {
    name                    = "AZ_VM-PublicIP-${count.index}"
    location                = azurerm_resource_group.rg.location
    resource_group_name     = azurerm_resource_group.rg.name
    allocation_method       = "Dynamic"
    count                   = 2
}
 resource "azurerm_network_interface" "rg" {
   count = 2  
   name                = "AZ-VM-00-NIC-${count.index}"
   location            = azurerm_resource_group.rg.location
   resource_group_name = azurerm_resource_group.rg.name
 ip_configuration {
     name                          = "internal"
     subnet_id                     = azurerm_subnet.rg.id
     private_ip_address_allocation = "Dynamic"
     public_ip_address_id = azurerm_public_ip.publicip.*.id[count.index]
   }
 }
 resource "azurerm_windows_virtual_machine" "rg" {
   count = 2  
   name                = "AZ-VM-${count.index}"
   resource_group_name = azurerm_resource_group.rg.name
   location            = azurerm_resource_group.rg.location
   size                = "Standard_B1s"
   admin_username      = "Administrator1 "
   admin_password      = "Password@123"
   network_interface_ids = [
     azurerm_network_interface.rg.*.id[count.index],
   ]
 os_disk {
     caching              = "ReadWrite"
     storage_account_type = "Standard_LRS"
   }
 source_image_reference {
     publisher = "MicrosoftWindowsServer"
     offer     = "WindowsServer"
     sku       = "2016-Datacenter"
     version   = "latest"
   }
 }