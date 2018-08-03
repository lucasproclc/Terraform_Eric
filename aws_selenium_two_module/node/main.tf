resource "aws_security_group" "allow_slave" {
  name        = "selenium slave security group"
  description = "Allow selenium slave inbound and outbound data"
  vpc_id    = "${var.node_vpc_id}"
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  ingress {
    from_port       = "${var.node_selenium_node_port}"
    to_port         = "${var.node_selenium_node_port}"
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
   egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "slave_node" {
  ami = "${var.node_image_id}"
  instance_type = "${var.node_selenium_node_instance_type}"
  key_name = "${var.node_key_name}"
  associate_public_ip_address = true
  vpc_security_group_ids = ["${aws_security_group.allow_slave.id}"]
  count = "${var.node_number_of_nodes}"
  subnet_id = "${var.node_subnet_id}"
  tags {
  Name="Selenium_slave_node"
  }
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = "${file("${var.node_private_key_path}")}"
    }
    script = "${path.module}/slave_requirements_script.sh"
  }
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = "${file("${var.node_private_key_path}")}"
    }
    inline = [
      "nohup java -jar selenium_server_standalone.jar -role node -hub http://${var.selenium_hub_url}/grid/register -port ${var.node_selenium_node_port} >> selenium_logs 2>&1 &",
      "sleep 10"
    ]
  }
}
