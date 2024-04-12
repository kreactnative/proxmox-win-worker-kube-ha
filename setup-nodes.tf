resource "null_resource" "setup_master_nodes" {
  depends_on = [module.master_domain]
  count      = length(module.master_domain)
  provisioner "file" {
    source      = "scripts/setup-k8s.sh"
    destination = "/tmp/setup-k8s.sh"
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.master_domain[count.index].address
      private_key = file("~/.ssh/id_rsa")
    }
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/setup-k8s.sh",
      "sudo /tmp/setup-k8s.sh"
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
resource "null_resource" "setup_work_nodes" {
  depends_on = [module.worker_domain]
  count      = length(module.worker_domain)
  provisioner "file" {
    source      = "scripts/setup-k8s.sh"
    destination = "/tmp/setup-k8s.sh"
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.worker_domain[count.index].address
      private_key = file("~/.ssh/id_rsa")
    }
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/setup-k8s.sh",
      "sudo /tmp/setup-k8s.sh"
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
