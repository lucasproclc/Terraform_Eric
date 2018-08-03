resource "azurerm_public_ip" "node_public_ip" {
  count                        = "${var.node_number_of_nodes}"
  name                         = "${var.node_public_ip_name}_${count.index}"
  location                     = "${var.node_resource_group_location}"
  resource_group_name          = "${var.node_resource_group_name}"
  public_ip_address_allocation = "static"
} 
resource "azurerm_network_security_group" "node_nsg" {
  name                = "${var.node_nsg_name}"
  location            = "${var.node_resource_group_location}"
  resource_group_name = "${var.node_resource_group_name}"

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
    name                       = "allow_selenium_node"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "${var.node_selenium_node_port}"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_network_interface" "node_nic" {
  count               = "${var.node_number_of_nodes}"
  name                = "${var.node_public_ip_nic_name}_${count.index}"
  location            = "${var.node_resource_group_location}"
  resource_group_name = "${var.node_resource_group_name}"
  network_security_group_id = "${azurerm_network_security_group.node_nsg.id}"
  ip_configuration {
    name                          = "ip_config"
    subnet_id                     = "${var.node_subnet_id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id = "${element(azurerm_public_ip.node_public_ip.*.id, count.index)}"
  }
}

resource "azurerm_virtual_machine" "node_vm" {
  count                 = "${var.node_number_of_nodes}"
  name                  = "${var.node_vm_name}_${count.index}"
  location              = "${var.node_resource_group_location}"
  resource_group_name   = "${var.node_resource_group_name}"
  network_interface_ids = ["${element(azurerm_network_interface.node_nic.*.id, count.index)}"]
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
    name              = "nodeosdisk${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "nodevirmac${count.index}"
    admin_username = "${var.nodevmusername}"
    admin_password = "${var.nodevmpassword}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}
resource "null_resource" "node_install" {
  count = "${var.node_number_of_nodes}"
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "${var.nodevmusername}"
      password = "${var.nodevmpassword}"
      host = "${element(azurerm_public_ip.node_public_ip.*.ip_address, count.index)}"
    }
    script = "${path.module}/slave_requirements_script.sh"
  }
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "${var.nodevmusername}"
      password = "${var.nodevmpassword}"
      host = "${element(azurerm_public_ip.node_public_ip.*.ip_address, count.index)}"
    }
    inline = [
      "nohup java -jar selenium_server_standalone.jar -role node -hub http://${var.selenium_hub_url}/grid/register -port ${var.node_selenium_node_port} >> selenium_logs 2>&1 &",
      "sleep 10",
    ]
  }
  depends_on = ["azurerm_virtual_machine.node_vm"]
}
output "node_public_ip" {
  value = ["${azurerm_public_ip.node_public_ip.*.ip_address}"]
}
output "node_public_port" {
  value = "${var.node_selenium_node_port}"
}
output "node_vm_name"{
  value = ["${azurerm_virtual_machine.node_vm.*.name}"]
}

