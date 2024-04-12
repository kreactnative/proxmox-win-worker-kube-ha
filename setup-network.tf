resource "null_resource" "setup_network" {
  depends_on = [module.master_domain, module.worker_domain, null_resource.init_master, null_resource.join_worker]
  provisioner "local-exec" {
    command = <<EOT
      chmod go-r ${path.cwd}/kube-config
      export KUBECONFIG=${path.cwd}/kube-config
      kubectl get nodes -owide
      kubectl taint nodes --all node-role.kubernetes.io/control-plane-
      curl -L https://github.com/projectcalico/calico/releases/download/v3.27.3/calicoctl-darwin-amd64 -o calicoctl
      chmod +x calicoctl
      curl https://raw.githubusercontent.com/projectcalico/calico/v3.27.3/manifests/tigera-operator.yaml -O
      sleep 10
      curl https://raw.githubusercontent.com/projectcalico/calico/v3.27.3/manifests/custom-resources.yaml -O
      sleep 10
      kubectl create -f tigera-operator.yaml
      sleep 10
      kubectl create -f custom-resources.yaml
      sleep 10
      kubectl apply -f ${path.cwd}/kubernetes/calico-felix-con.yaml
      kubectl apply -f ${path.cwd}/kubernetes/calico-ip-pool.yaml
      sleep 20
      kubectl apply -f ${path.cwd}/kubernetes/calico-install.yaml
      ./calicoctl ipam configure --strictaffinity=true --allow-version-mismatch
    EOT
  }
}
