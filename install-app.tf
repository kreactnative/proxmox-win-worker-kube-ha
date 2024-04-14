resource "null_resource" "install_app" {
  depends_on = [null_resource.join_win_worker_node]
  provisioner "local-exec" {
    command = <<EOT
      chmod go-r ${path.cwd}/kube-config
      export KUBECONFIG=${path.cwd}/kube-config
      kubectl get nodes -owide
      # install metrics-server
      kubectl apply -f  ${path.cwd}/kubernetes/metrics-server
      # patch calico stystem
      kubectl patch deployment calico-kube-controllers --patch-file ${path.cwd}/kubernetes/patch-calico-controller.yaml -n calico-system
      kubectl rollout restart deployment calico-typha -n calico-system
      kubectl rollout restart ds calico-node -n calico-system
      kubectl delete pod --all -n calico-system
      # metallb system
      kubectl create ns metallb-system
      kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
      kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.4/config/manifests/metallb-native.yaml
      kubectl patch deployment controller --patch-file ${path.cwd}/kubernetes/patch-host-network.yaml -n metallb-system
      sleep 20
      kubectl rollout restart ds speaker -n metallb-system
      kubectl rollout restart deployment controller -n metallb-system
      sleep 50
      kubectl apply -f ${path.cwd}/kubernetes/metallb/configmap.yaml
    EOT
  }
}
