provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}
data "aws_ami" "ubuntu" {
  most_recent      = true
  filter {
    name   = "name"
    values = ["*ubuntu-xenial-16.04-amd64-server-*"]
  }
  filter {
    name   = "description"
    values = ["*Canonical*", "*LTS*", "*Ubuntu*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}
resource "aws_key_pair" "deployer" {
  key_name   = "${var.public_key_name}"
  public_key = "${file("${var.public_key_path}")}"
}
module "hub" {
  source = "./hub/"
  hub_vpc_id    = "${var.vpc_id}"
  hub_subnet_id = "${var.subnet_id}"
  hub_selenium_hub_instance_type = "${var.selenium_hub_instance_type}"
  hub_selenium_hub_port = "${var.selenium_hub_port}"
  hub_image_id = "${data.aws_ami.ubuntu.image_id}"
  hub_key_name = "${aws_key_pair.deployer.key_name}"
  hub_private_key_path = "${var.private_key_path}"
}
module "node" {
  source = "./node/"
  node_vpc_id = "${var.vpc_id}"
  node_subnet_id = "${var.subnet_id}"
  selenium_hub_url = "${module.hub.hub_url}"
  node_number_of_nodes = "${var.number_of_nodes}"
  node_selenium_node_port = "${var.selenium_node_port}"
  node_selenium_node_instance_type = "${var.selenium_node_instance_type}"
  node_image_id = "${data.aws_ami.ubuntu.image_id}"
  node_key_name = "${aws_key_pair.deployer.key_name}"
  node_private_key_path = "${var.private_key_path}"
}