resource "null_resource" "restart_master" {
  depends_on = [null_resource.join_win_worker_node, null_resource.install_app]
  count      = length(module.master_domain)
  provisioner "remote-exec" {
    inline = [
      "sudo reboot"
    ]
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.master_domain[count.index].address
      private_key = file("~/.ssh/id_rsa")
      timeout     = "20s"
    }
  }
}
resource "null_resource" "restart_worker" {
  depends_on = [null_resource.join_win_worker_node, null_resource.install_app]
  count      = length(module.worker_domain)
  provisioner "remote-exec" {
    inline = [
      "sudo reboot"
    ]
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.worker_domain[count.index].address
      private_key = file("~/.ssh/id_rsa")
      timeout     = "20s"
    }
  }
}
