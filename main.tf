provider "azurerm" {

  version = "=2.1.0"

  features {}

}

##############

#Nome Projeto#

##############

variable "prefix" {

  default = "pudim"

}



################

#Resource Group#

################

resource "azurerm_resource_group" "main" {

  name     = "${var.prefix}-resources"

  location = "East US"

}



##############

#Rede Virtual#

##############

resource "azurerm_virtual_network" "main" {

  name                = "${var.prefix}-network"

  address_space       = ["10.0.0.0/16"]

  location            = azurerm_resource_group.main.location

  resource_group_name = azurerm_resource_group.main.name

}



########

#Subnet#

########

resource "azurerm_subnet" "internal" {

  name                 = "internal"

  resource_group_name  = azurerm_resource_group.main.name

  virtual_network_name = azurerm_virtual_network.main.name

  address_prefix       = "10.0.2.0/24"

}



############

#IP Publico#

############

resource "azurerm_public_ip" "main" {

  name                = "acceptanceTestPublicIp1"

  resource_group_name = azurerm_resource_group.main.name

  location            = azurerm_resource_group.main.location

  allocation_method   = "Dynamic"

}



###############

#Placa de Rede#

###############

resource "azurerm_network_interface" "main" {

  name                = "${var.prefix}-nic"

  location            = azurerm_resource_group.main.location

  resource_group_name = azurerm_resource_group.main.name



  ip_configuration {

    name                          = "testconfiguration1"

    subnet_id                     = azurerm_subnet.internal.id

    private_ip_address_allocation = "Dynamic"

    public_ip_address_id          = azurerm_public_ip.main.id

  }

}





#################

#Maquina Virtual#

#################

resource "azurerm_virtual_machine" "main" {

  name                  = "${var.prefix}-vm"

  location              = azurerm_resource_group.main.location

  resource_group_name   = azurerm_resource_group.main.name

  network_interface_ids = [azurerm_network_interface.main.id]

  vm_size               = "Standard_B1ls"



  # Uncomment this line to delete the OS disk automatically when deleting the VM

  delete_os_disk_on_termination = true



  # Uncomment this line to delete the data disks automatically when deleting the VM

  delete_data_disks_on_termination = true



  storage_image_reference {

    publisher = "Canonical"

    offer     = "UbuntuServer"

    sku       = "18.04-LTS"

    version   = "latest"

  }

  storage_os_disk {

    name              = "myosdisk1"

    caching           = "ReadWrite"

    create_option     = "FromImage"

    managed_disk_type = "Standard_LRS"

  }

  os_profile {

    computer_name  = "bananas"

    admin_username = "ubuntu"

    admin_password = "Password1234!"

  }

  os_profile_linux_config {

    disable_password_authentication = false

    ssh_keys {

      key_data = file("~/.ssh/id_rsa.pub")

      path     = "/home/ubuntu/.ssh/authorized_keys"

    }

  }



  tags = {

    environment = "staging"

  }

}

