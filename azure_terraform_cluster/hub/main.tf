resource "azurerm_public_ip" "hub_public_ip" {
  name                         = "${var.hub_public_ip_name}"
  location                     = "${var.hub_resource_group_location}"
  resource_group_name          = "${var.hub_resource_group_name}"
  public_ip_address_allocation = "static"
} 
resource "azurerm_network_security_group" "hub_nsg" {
  name                = "${var.hub_nsg_name}"
  location            = "${var.hub_resource_group_location}"
  resource_group_name = "${var.hub_resource_group_name}"

  security_rule {
    name                       = "allow_ssh"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow_selenium_hub"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "${var.hub_selenium_hub_port}"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_network_interface" "hub_nic" {
  name                = "${var.hub_public_ip_nic_name}"
  location            = "${var.hub_resource_group_location}"
  resource_group_name = "${var.hub_resource_group_name}"
  network_security_group_id = "${azurerm_network_security_group.hub_nsg.id}"
  ip_configuration {
    name                          = "ip_config"
    subnet_id                     = "${var.hub_subnet_id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id = "${azurerm_public_ip.hub_public_ip.id}"
  }
}

resource "azurerm_virtual_machine" "hub_vm" {
  name                  = "${var.hub_vm_name}"
  location              = "${var.hub_resource_group_location}"
  resource_group_name   = "${var.hub_resource_group_name}"
  network_interface_ids = ["${azurerm_network_interface.hub_nic.id}"]
  vm_size               = "Standard_B1s"
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myhubosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "hubvirmac"
    admin_username = "${var.hubvmusername}"
    admin_password = "${var.hubvmpassword}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}
output "hub_public_ip" {
  value = "${azurerm_public_ip.hub_public_ip.ip_address}"
}
output "hub_public_port" {
  value = "${var.hub_selenium_hub_port}"
}
output "hub_vm_name"{
  value = "${azurerm_virtual_machine.hub_vm.name}"
}

