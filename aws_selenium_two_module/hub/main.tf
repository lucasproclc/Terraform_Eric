resource "aws_security_group" "allow_hub" {
  name        = "selenium hub security group"
  description = "Allow selenium slave inbound and outbound data"
  vpc_id    = "${var.hub_vpc_id}"
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  ingress {
    from_port       = "${var.hub_selenium_hub_port}"
    to_port         = "${var.hub_selenium_hub_port}"
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
resource "aws_instance" "hub_node" {
  ami = "${var.hub_image_id}"
  instance_type = "${var.hub_selenium_hub_instance_type}"
  associate_public_ip_address = true
  key_name = "${var.hub_key_name}"
  vpc_security_group_ids = ["${aws_security_group.allow_hub.id}"]
  subnet_id = "${var.hub_subnet_id}"
  tags {
  Name="Selenium_hub_node"
  }
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "ubuntu"
      host = "${aws_instance.hub_node.public_ip}"
      private_key = "${file("${var.hub_private_key_path}")}"
    }
    script = "${path.module}/hub_requirements_script.sh"
  }
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "ubuntu"
      host = "${aws_instance.hub_node.public_ip}"
      private_key = "${file("${var.hub_private_key_path}")}"
    }
    inline = [
      "nohup java -jar selenium_server_standalone.jar -role hub -port ${var.hub_selenium_hub_port} >> selenium_logs 2>&1 &",
      "sleep 10"
    ]
  }
}
output "hub_url" {
  value = "${aws_instance.hub_node.public_ip}:${var.hub_selenium_hub_port}"
}
