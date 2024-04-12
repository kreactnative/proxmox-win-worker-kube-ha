resource "null_resource" "copy_master_config" {
  depends_on = [null_resource.setup_network]
  count      = length(module.win_worker_domain)
  provisioner "remote-exec" {
    inline = [
      "sudo dnf install sshpass -y",
      "sudo sshpass -p 'Kdotnet34567@' ssh -o StrictHostKeyChecking=no administrator@${module.win_worker_domain[count.index].address} 'mkdir c:\\k'",
      "sudo sshpass -p 'Kdotnet34567@' scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r /root/.kube administrator@${module.win_worker_domain[count.index].address}:/users/administrator",
      "sudo sshpass -p 'Kdotnet34567@' scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r /root/.kube/config administrator@${module.win_worker_domain[count.index].address}:/k/",
      "sudo sshpass -p 'Kdotnet34567@' ssh -o StrictHostKeyChecking=no administrator@${module.win_worker_domain[count.index].address} 'powershell Rename-Computer -NewName \"${module.win_worker_domain[count.index].name}\" -Restart'",
      "exit 0"
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

resource "null_resource" "join_win_worker_node" {
  depends_on = [null_resource.copy_master_config]
  count      = length(module.win_worker_domain)
  provisioner "remote-exec" {
    inline = [
      "powershell",
      "Invoke-WebRequest -Uri https://github.com/projectcalico/calico/releases/download/v3.27.3/install-calico-windows.ps1 -OutFile c:\\k\\install-calico-windows.ps1",
      "c:\\k\\install-calico-windows.ps1 -ReleaseBaseURL \"https://github.com/projectcalico/calico/releases/download/v3.27.3\" -ReleaseFile \"calico-windows-v3.27.3.zip\" -KubeVersion \"1.29.3\" -DownloadOnly \"yes\" -ServiceCidr \"10.96.0.0/24\" -DNSServerIPs \"127.0.0.1\"",
      "$ENV:CNI_BIN_DIR=\"c:\\program files\\containerd\\cni\\bin\"",
      "$ENV:CNI_CONF_DIR=\"c:\\program files\\containerd\\cni\\conf\"",
      "c:\\calicowindows\\install-calico.ps1",
      "c:\\calicowindows\\start-calico.ps1",
      "c:\\calicowindows\\kubernetes\\install-kube-services.ps1",
      "New-NetFirewallRule -Name 'Kubelet-In-TCP' -DisplayName 'Kubelet (node)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 10250",
      "Start-Service kubelet",
      "Start-Service kube-proxy",
      "kubectl get nodes -o wide"
    ]
    connection {
      type     = "ssh"
      user     = "administrator"
      host     = module.win_worker_domain[0].address
      password = "Kdotnet34567@"
    }
  }
}
