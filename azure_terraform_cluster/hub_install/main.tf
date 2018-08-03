resource "null_resource" "hub_install" {
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "${var.hub_vir_mac_username}"
      password = "${var.hub_vir_mac_password}"
      host = "${var.hub_vir_mac_ip}"
    }
    script = "${path.module}/hub_requirements_script.sh"
  }
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "${var.hub_vir_mac_username}"
      password = "${var.hub_vir_mac_password}"
      host = "${var.hub_vir_mac_ip}"
    }
    inline = [
      "nohup java -jar selenium_server_standalone.jar -role hub -port ${var.hub_vir_mac_port} >> selenium_logs 2>&1 &",
      "sleep 10",
      "echo ${var.hub_vir_mac_name}"
    ]
  }
}
output "hub_url" {
  value = "${var.hub_vir_mac_ip}:${var.hub_vir_mac_port}"
}

