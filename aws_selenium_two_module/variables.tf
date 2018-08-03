#required_variables
variable "access_key" {}
variable "secret_key" {}
variable "public_key_name" {}
variable "public_key_path" {}
variable "private_key_path" {}

#optional_variables
variable "region" {
  default = "us-east-1"
}
variable "vpc_id" {
  default = "vpc-20542145"
}
variable "subnet_id" {
  default = "subnet-026afd75"
}
variable "selenium_hub_port" {
  default = "4444"
}
variable "selenium_hub_instance_type" {
  default = "t2.micro"
}
variable "number_of_nodes" {
  default = "1"
}
variable "selenium_node_port" {
  default = "5555"
}
variable "selenium_node_instance_type" {
  default = "t2.micro"
}
