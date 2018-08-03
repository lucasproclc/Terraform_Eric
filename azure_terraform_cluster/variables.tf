#required_variables
variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}
variable "resource_group_name" {}
variable "resource_group_location" {}
variable "virtual_network_name" {}
variable "virtual_network_address_space" {}
variable "subnet_name" {}
variable "subnet_address_space" {}
variable "hub_vm_public_ip_name" {}
variable "hub_vm_public_ip_nic_name" {}
variable "hub_vm_nsg_name" {}
variable "selenium_hub_vm_name" {}
variable "vmusername" {}
variable "vmpassword" {}
variable "node_vm_public_ip_name" {}
variable "node_vm_public_ip_nic_name" {}
variable "node_vm_nsg_name" {}
variable "selenium_node_vm_name" {}
variable "number_of_nodes" {
  default = "1"
}
variable "selenium_hub_port" {
  default = "4444"
}
variable "selenium_node_port" {
  default = "5555"
}