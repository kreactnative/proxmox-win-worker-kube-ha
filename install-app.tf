resource "null_resource" "install_app" {
  depends_on = [null_resource.join_win_worker_node, null_resource.setup_network, null_resource.rename_win_worker]
  provisioner "local-exec" {
    command = <<EOT
      chmod go-r ${path.cwd}/kube-config
      export KUBECONFIG=${path.cwd}/kube-config
      kubectl get nodes -owide
      kubectl create ns metallb-system
      kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
      kubectl apply -f  ${path.cwd}/kubernetes/metrics-server
      kubectl apply -f  ${path.cwd}/kubernetes/metallb
      istioctl install -f ${path.cwd}/kubernetes/istio/istio-operator.yaml -y
    EOT
  }
}
