#!/bin/bash
cd /tmp/ || exit
kubectl apply -f metric-server.yaml
#helm repo add metallb https://metallb.github.io/metallb
#helm repo update
#kubectl create namespace metallb-system
#helm upgrade --install metallb metallb/metallb -n  metallb-system
#kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
kubectl taint nodes --all node-role.kubernetes.io/control-plane-

curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.21.0 sh -
cd istio-1.21.0/bin || exit
sudo chmod +x istioctl
./istioctl install -f /tmp/istio-operator.yaml -y

cd /tmp/ || exit
kubectl apply -f cilium-ip.yaml
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm upgrade --install kube-prometheus-stack  --create-namespace  --namespace kube-prometheus-stack  prometheus-community/kube-prometheus-stack -f prometheus-stack-values.yaml
helm repo add grafana https://grafana.github.io/helm-charts
helm upgrade --install loki grafana/loki-stack --namespace loki --create-namespace --set grafana.enabled=false
helm repo add jetstack https://charts.jetstack.io
helm upgrade --install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --set installCRDs=true
cd /tmp/ || exit
kubectl apply -f loki-secret.yaml
kubectl rollout restart statefulset loki -n loki
kubectl apply -f ssl.yaml
kubectl apply -f istio-app.yaml
kubectl apply -f istio-brotli.yaml
kubectl apply -f istio-filter.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/grafana.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/kiali.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/prometheus.yaml