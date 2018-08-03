#Azure credentials
subscription_id = 
client_id =
client_secret = 
tenant_id = 

#Required variables
resource_group_name = "abhishektestResourceGroup1"
resource_group_location = "West US"
virtual_network_name = "terraform_vnet"
virtual_network_address_space = "10.0.1.0/24"
subnet_name = "terraform_subnet"
subnet_address_space = "10.0.1.0/26"
hub_vm_public_ip_name = "hub_public_ip"
hub_vm_public_ip_nic_name = "hub_public_ip_nic"
hub_vm_nsg_name = "hub_nsg"
selenium_hub_vm_name = "selenium_hub_vm"
vmusername = "adminuser"
vmpassword = "password@123"
node_vm_public_ip_name = "node_public_ip"
node_vm_public_ip_nic_name = "node_public_ip_nic"
node_vm_nsg_name = "node_nsg"
selenium_node_vm_name = "selenium_node_vm"
#optional variables
number_of_nodes = 3
selenium_hub_port = "4444"
selenium_node_port = "5555"