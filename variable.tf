variable "azurerm_nic" {
 type = list
   default = ["Master","Node1","Node2"]  
 
}

variable "vmname" {
  type = list
  default = ["Master","Node1","Node2"]
}