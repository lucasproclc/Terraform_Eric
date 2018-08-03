resource "null_resource" "node_install" {
  count = "${var.node_number_of_vm_nodes}"
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "${var.node_vir_mac_username}"
      password = "${var.node_vir_mac_password}"
      host = "${var.node_vir_mac_ip[0]}"
    }
    script = "${path.module}/slave_requirements_script.sh"
  }
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "${var.node_vir_mac_username}"
      password = "${var.node_vir_mac_password}"
      host = "${var.node_vir_mac_ip[0]}"
    }
    inline = [
      "nohup java -jar selenium_server_standalone.jar -role node -hub http://${var.selenium_hub_url}/grid/register -port ${var.node_vir_mac_port} >> selenium_logs 2>&1 &",
      "sleep 10",
      "echo ${var.node_vir_mac_name}"
    ]
  }
}
