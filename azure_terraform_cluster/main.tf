provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  client_id = "${var.client_id}"
  client_secret = "${var.client_secret}"
  tenant_id = "${var.tenant_id}"
}
resource "azurerm_resource_group" "resource_grp" {
  name     = "${var.resource_group_name}"
  location = "${var.resource_group_location}"
}
resource "azurerm_virtual_network" "vir_net" {
  name                = "${var.virtual_network_name}"
  resource_group_name = "${azurerm_resource_group.resource_grp.name}"
  address_space       = ["${var.virtual_network_address_space}"]
  location            = "${var.resource_group_location}"
}
resource "azurerm_subnet" "subnet" {
  name                 = "${var.subnet_name}"
  resource_group_name  = "${azurerm_resource_group.resource_grp.name}"
  virtual_network_name = "${azurerm_virtual_network.vir_net.name}"
  address_prefix       = "${var.subnet_address_space}"
}
module "hub" {
  source = "./hub/"
  hub_public_ip_name = "${var.hub_vm_public_ip_name}"
  hub_resource_group_location = "${azurerm_resource_group.resource_grp.location}"
  hub_resource_group_name = "${azurerm_resource_group.resource_grp.name}"
  hub_public_ip_nic_name = "${var.hub_vm_public_ip_nic_name}"
  hub_subnet_id = "${azurerm_subnet.subnet.id}"
  hub_nsg_name = "${var.hub_vm_nsg_name}"
  hub_selenium_hub_port = "${var.selenium_hub_port}"
  hub_vm_name = "${var.selenium_hub_vm_name}"
  hubvmusername = "${var.vmusername}"
  hubvmpassword = "${var.vmpassword}"
}
module "hub_install" {
  source = "./hub_install/"
  hub_vir_mac_ip = "${module.hub.hub_public_ip}"
  hub_vir_mac_port = "${module.hub.hub_public_port}"
  hub_vir_mac_username = "${var.vmusername}"
  hub_vir_mac_password = "${var.vmpassword}"
  hub_vir_mac_name = "${module.hub.hub_vm_name}"
}
module "node" {
  source = "./node/"
  node_public_ip_name = "${var.node_vm_public_ip_name}"
  node_resource_group_location = "${azurerm_resource_group.resource_grp.location}"
  node_resource_group_name = "${azurerm_resource_group.resource_grp.name}"
  node_public_ip_nic_name = "${var.node_vm_public_ip_nic_name}"
  node_subnet_id = "${azurerm_subnet.subnet.id}"
  node_nsg_name = "${var.node_vm_nsg_name}"
  node_selenium_node_port = "${var.selenium_node_port}"
  node_vm_name = "${var.selenium_node_vm_name}"
  nodevmusername = "${var.vmusername}"
  nodevmpassword = "${var.vmpassword}"
  node_number_of_nodes = "${var.number_of_nodes}"
  selenium_hub_url = "${module.hub_install.hub_url}"
}
