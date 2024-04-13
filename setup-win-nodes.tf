resource "null_resource" "rename_win_worker" {
  depends_on = [null_resource.setup_network]
  count      = length(module.win_worker_domain)
  provisioner "remote-exec" {
    inline = [
      "sudo dnf install sshpass -y",
      "rm -rf /tmp/rename_win_worker${count.index}.ps1 && echo Rename-Computer -NewName ${module.win_worker_domain[count.index].name} -Restart >> /tmp/rename_win_worker${count.index}.ps1",
      "sudo sshpass -p 'Kdotnet34567@' scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r /tmp/rename_win_worker${count.index}.ps1 administrator@${module.win_worker_domain[count.index].address}:/users/administrator",
    ]
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.master_domain[0].address
      private_key = file("~/.ssh/id_rsa")
      timeout     = "20s"
    }
  }
  provisioner "remote-exec" {
    inline = [
      "sudo dnf install sshpass -y",
      "sudo sshpass -p 'Kdotnet34567@' ssh -o StrictHostKeyChecking=no administrator@${module.win_worker_domain[count.index].address} 'powershell c:\\users\\administrator\\rename_win_worker${count.index}.ps1'"
    ]
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.master_domain[0].address
      private_key = file("~/.ssh/id_rsa")
      timeout     = "20s"
    }
  }
}

resource "null_resource" "copy_master_config" {
  depends_on = [null_resource.setup_network, null_resource.rename_win_worker]
  count      = length(module.win_worker_domain)

  provisioner "file" {
    source      = "scripts/join_win_worker.ps1"
    destination = "/tmp/join_win_worker.ps1"
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.master_domain[0].address
      private_key = file("~/.ssh/id_rsa")
    }
  }
  provisioner "remote-exec" {
    inline = [
      "sudo dnf install sshpass -y",
      "sleep 30",
      "sudo sshpass -p 'Kdotnet34567@' ssh -o StrictHostKeyChecking=no administrator@${module.win_worker_domain[count.index].address} 'mkdir c:\\k'",
      "sudo sshpass -p 'Kdotnet34567@' scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r /root/.kube administrator@${module.win_worker_domain[count.index].address}:/users/administrator",
      "sudo sshpass -p 'Kdotnet34567@' scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r /root/.kube/config administrator@${module.win_worker_domain[count.index].address}:/k/",
      "sudo sshpass -p 'Kdotnet34567@' scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r /tmp/join_win_worker.ps1 administrator@${module.win_worker_domain[count.index].address}:/users/administrator"
    ]
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.master_domain[0].address
      private_key = file("~/.ssh/id_rsa")
      timeout     = "20s"
    }
  }
  provisioner "remote-exec" {
    inline = [
      "sudo dnf install sshpass -y",
      "sleep 20",
      "sudo sshpass -p 'Kdotnet34567@' ssh -o StrictHostKeyChecking=no administrator@${module.win_worker_domain[count.index].address} 'powershell c:\\users\\administrator\\join_win_worker.ps1'"
    ]
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.master_domain[0].address
      private_key = file("~/.ssh/id_rsa")
      timeout     = "20s"
    }
  }
}
