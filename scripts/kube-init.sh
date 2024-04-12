#!/bin/bash
cd /tmp/ 
sudo kubeadm init
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo cp -i /etc/kubernetes/admin.conf /tmp/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
sudo chown -R rocky:rocky /tmp/config
export KUBECONFIG=/tmp/config
sudo chmod 644 /etc/kubernetes/admin.conf
sudo kubeadm token create --print-join-command >> join-worker.sh
sudo chown -R rocky:rocky join-worker.sh
export KUBECONFIG=/etc/kubernetes/admin.conf