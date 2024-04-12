resource "null_resource" "init_master" {
  depends_on = [null_resource.setup_master_nodes]
  provisioner "file" {
    source      = "scripts/kube-init.sh"
    destination = "/tmp/kube-init.sh"
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.master_domain[0].address
      private_key = file("~/.ssh/id_rsa")
    }
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/kube-init.sh",
      "sudo /tmp/kube-init.sh"
    ]
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.master_domain[0].address
      private_key = file("~/.ssh/id_rsa")
      timeout     = "20s"
    }
  }
  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ~/.ssh/id_rsa ${var.user}@${module.master_domain[0].address}:/tmp/config $HOME/.kube/proxmox-terraform-k8s-win-worker"
  }
    provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ~/.ssh/id_rsa ${var.user}@${module.master_domain[0].address}:/tmp/config  ${path.cwd}/kube-config"
  }
  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ~/.ssh/id_rsa ${var.user}@${module.master_domain[0].address}:/tmp/join-worker.sh join-worker.sh"
  }
}

resource "null_resource" "join_worker" {
  depends_on = [null_resource.setup_master_nodes, null_resource.setup_work_nodes, null_resource.init_master]
  count      = length(module.worker_domain)
  provisioner "file" {
    source      = "join-worker.sh"
    destination = "/tmp/join-worker.sh"
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.worker_domain[count.index].address
      private_key = file("~/.ssh/id_rsa")
    }
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/join-worker.sh",
      "sudo /tmp/join-worker.sh"
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
