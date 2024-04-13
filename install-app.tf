resource "null_resource" "install_app" {
  depends_on = [null_resource.join_win_worker_node]
  provisioner "local-exec" {
    command = <<EOT
      chmod go-r ${path.cwd}/kube-config
      export KUBECONFIG=${path.cwd}/kube-config
      kubectl get nodes -owide
      kubectl patch deployment calico-kube-controllers --patch-file ${path.cwd}/kubernetes/patch-calico-controller.yaml -n calico-system
      kubectl create ns metallb-system
      kubectl create secret generic -n metallb-system metallb-memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
      helm repo add metallb https://metallb.github.io/metallb
      helm repo update
      helm upgrade --install metallb metallb/metallb -n metallb-system
      sleep 20
      kubectl apply -f ${path.cwd}/kubernetes/metallb/configmap.yaml
      kubectl apply -f  ${path.cwd}/kubernetes/metrics-server
      kubectl patch deployment metrics-server --patch-file ${path.cwd}/kubernetes/metrics-server/patch-metrics-server.yaml -n kube-system
      istioctl install -f ${path.cwd}/kubernetes/istio/istio-operator.yaml -y
    EOT
  }
}
