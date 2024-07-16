---
title: Kubernetes - An open-source container orchestration system 🚢
date: 2024-07-16 8:27:00 
categories: [Container-orchestration]
tags: [Container-orchestration]
image:
  path: /assets/img/Posts/kubernetes-cover.webp
---

# Getting ready
## For all nodes

### Disable swapoff
```shell
sudo su
swapoff -a; sed -i '/swap/d' /etc/fstab
```
### Install Containerd
```shell
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sudo sysctl --system
sudo apt install containerd -y
mkdir /etc/containerd
containerd config default > /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
systemctl restart containerd
```

### Install Kubeadm, Kubectl, Kubelet
```shell
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
```

```shell
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

```shell
sudo apt-get update
sudo apt update
```

```shell
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

## Master node only
### Initialize cluster
```shell
sudo kubeadm init --control-plane-endpoint=192.168.1.x --node-name controller --pod-network-cidr=10.244.0.0/16
```
Things have to change
`--control-plane-endpoint=<your-hostname-or-ip>`
`--node-name <your-server-hostname>`
> Things have to change
> `--control-plane-endpoint=<your-hostname-or-ip>`
> `--node-name <your-server-hostname>`
{: .prompt-tip }

The join command should look like this
```shell
mkdir -p $HOME/.kube  
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config  
sudo chown $(id -u):$(id -g) $HOME/.kube/config

export KUBECONFIG=/etc/kubernetes/admin.conf

kubeadm join 10.0.1.47:6443 --token jqc69r.djvkfmrmoj201f3e \
        --discovery-token-ca-cert-hash sha256:2bda7403a0e3fb26f6df54f6446517881845596c1ef26ce8420942fd40a2c87c \
        --control-plane
        
kubeadm join 10.0.1.47:6443 --token jqc69r.djvkfmrmoj201f3e \
        --discovery-token-ca-cert-hash sha256:2bda7403a0e3fb26f6df54f6446517881845596c1ef26ce8420942fd40a2c87c
```

### Install Kubernetes network plugin
```shell
kubectl get pods --all-namespaces
```

```shell
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
```

