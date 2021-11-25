
 resource "azurerm_resource_group" "rg" {
   name     = "Demo-K8S-RG"
   location = "eastus"
   provider = azurerm.spoke2
 }
  resource "azurerm_virtual_network" "rg" {
   name                = "K8S-network"
   address_space       = ["10.0.0.0/16"]
   location            = azurerm_resource_group.rg.location
   resource_group_name = azurerm_resource_group.rg.name
   provider = azurerm.spoke2
 }
 resource "azurerm_subnet" "rg" {
   name                 = "internal"
   resource_group_name  = azurerm_resource_group.rg.name
   virtual_network_name = azurerm_virtual_network.rg.name
   address_prefixes     = ["10.0.1.0/24"]
   provider = azurerm.spoke2
 }
 resource "azurerm_public_ip" "publicip" {
    name                    = "K8S-${var.azurerm_nic[count.index]}-pip"
    location                = azurerm_resource_group.rg.location
    resource_group_name     = azurerm_resource_group.rg.name
    allocation_method       = "Dynamic"
    count                   = length(var.azurerm_nic)
    provider = azurerm.spoke2
}
 resource "azurerm_network_interface" "rg" {
   count = length(var.azurerm_nic)
   name                = "K8S-${var.azurerm_nic[count.index]}-NIC"
   location            = azurerm_resource_group.rg.location
   resource_group_name = azurerm_resource_group.rg.name
   provider = azurerm.spoke2
 ip_configuration {
     name                          = "internal"
     subnet_id                     = azurerm_subnet.rg.id
     private_ip_address_allocation = "Dynamic"
     public_ip_address_id = azurerm_public_ip.publicip.*.id[count.index]
   }
 }
 resource "azurerm_linux_virtual_machine" "rg" {
   count = length(var.vmname)
   name                = "K8S-${var.azurerm_nic[count.index]}-VM"
   resource_group_name = azurerm_resource_group.rg.name
   location            = azurerm_resource_group.rg.location
   provider = azurerm.spoke2
   size                = "Standard_B1s"
   admin_username      = "Administrator1 "
   admin_password      = "Password@123"
   disable_password_authentication = false
   network_interface_ids = [
     azurerm_network_interface.rg.*.id[count.index],
   ]
 os_disk {
        name              = "k8sdisk-${var.azurerm_nic[count.index]}"
        caching           = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }
 source_image_reference {
        publisher = "OpenLogic"
        offer     = "CentOS"
        sku       = "7.5"
        version   = "latest"
    }
 }