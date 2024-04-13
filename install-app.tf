resource "null_resource" "install_app" {
  depends_on = [null_resource.join_win_worker_node]
  provisioner "local-exec" {
    command = <<EOT
      chmod go-r ${path.cwd}/kube-config
      export KUBECONFIG=${path.cwd}/kube-config
      kubectl get nodes -owide
      kubectl patch deployment calico-kube-controllers --patch-file ${path.cwd}/kubernetes/patch-calico-controller.yaml -n calico-system
      kubectl patch deployment metrics-server --patch-file ${path.cwd}/kubernetes/patch-calico-controller.yaml -n kube-system
      kubectl create ns metallb-system
      kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
      kubectl apply -f  ${path.cwd}/kubernetes/metrics-server
      kubectl apply -f  ${path.cwd}/kubernetes/metallb
      istioctl install -f ${path.cwd}/kubernetes/istio/istio-operator.yaml -y
    EOT
  }
}
