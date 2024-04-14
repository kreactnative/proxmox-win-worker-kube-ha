Invoke-WebRequest -Uri https://github.com/projectcalico/calico/releases/download/v3.27.3/install-calico-windows.ps1 -OutFile c:\k\install-calico-windows.ps1
c:\k\install-calico-windows.ps1 -ReleaseBaseURL "https://github.com/projectcalico/calico/releases/download/v3.27.3" -ReleaseFile "calico-windows-v3.27.3.zip" -KubeVersion "1.28.8" -DownloadOnly "yes" -ServiceCidr "10.96.0.0/24" -DNSServerIPs "127.0.0.1"
$ENV:CNI_BIN_DIR="c:\program files\containerd\cni\bin"
$ENV:CNI_CONF_DIR="c:\program files\containerd\cni\conf"
c:\calicowindows\install-calico.ps1
c:\calicowindows\start-calico.ps1
c:\calicowindows\kubernetes\install-kube-services.ps1
New-NetFirewallRule -Name 'Kubelet-In-TCP' -DisplayName 'Kubelet (node)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 10250
Start-Service kubelet
Start-Service kube-proxy
kubectl get nodes -o wide
Restart-Computer -Force