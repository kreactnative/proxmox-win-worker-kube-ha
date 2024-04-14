c:\calicowindows\kubernetes\install-kube-services.ps1
Start-Service kubelet
Start-Service kube-proxy
kubectl get nodes -o wide
Restart-Computer -Force