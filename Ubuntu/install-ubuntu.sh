#!/bin/sh
# Use this script to setup any node in your Kuberntes cluster 
# Either master or worker
# Source: http://kubernetes.io/docs/getting-started-guides/kubeadm/

### setup terminal
KUBE_VERSION=1.21.1
### Setting up background to operate Kubernetes
echo 'colorscheme ron' >> ~/.vimrc
echo 'set tabstop=2' >> ~/.vimrc
echo 'set shiftwidth=2' >> ~/.vimrc
echo 'set expandtab' >> ~/.vimrc
echo 'source <(kubectl completion bash)' >> ~/.bashrc
echo 'alias k=kubectl' >> ~/.bashrc
echo 'alias c=clear' >> ~/.bashrc
echo 'complete -F __start_kubectl k' >> ~/.bashrc
sed -i '1s/^/force_color_prompt=yes\n/' ~/.bashrc

apt-get update 
apt-get install wget apt-transport-https gnupg lsb-release -y

curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF > /etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

### install k8s and docker
apt-get remove -y docker.io kubelet kubeadm kubectl kubernetes-cni docker-ce
apt-get autoremove -y
systemctl daemon-reload

apt-get update -y
apt-get -y install linux-headers-$(uname -r)
apt-get install -y etcd-client vim build-essential bash-completion binutils apparmor-utils docker.io kubelet=${KUBE_VERSION}-00 kubeadm=${KUBE_VERSION}-00 kubectl=${KUBE_VERSION}-00 kubernetes-cni=0.8.7-00 

cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "storage-driver": "overlay2"
}
EOF
mkdir -p /etc/systemd/system/docker.service.d

# Restart docker.
systemctl daemon-reload
systemctl restart docker

# start docker on reboot
systemctl enable docker

docker info | grep -i "storage"
docker info | grep -i "cgroup"

systemctl enable kubelet && systemctl start kubelet