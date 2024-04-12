resource "null_resource" "setup_network" {
  depends_on = [module.master_domain, module.worker_domain, null_resource.init_master, null_resource.join_worker]
  provisioner "local-exec" {
    command = <<EOT
      chmod go-r ${path.cwd}/kube-config
      export KUBECONFIG=${path.cwd}/kube-config
      kubectl get nodes -owide
    EOT
  }
}
