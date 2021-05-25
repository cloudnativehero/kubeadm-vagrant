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

#Turn off Swap
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
swapoff -a

rm -rf ~/.kube /etc/cni/net.d /etc/kubernetes /var/lib/etcd /var/lib/kubelet /var/run/kubernetes /var/lib/cni /opt/cni
iptables -F

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

HOST_IP=`/sbin/ifconfig eth1 | egrep -o 'inet [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'  | cut -d' ' -f2`
ip route add 10.96.0.0/16 dev eth1 src ${HOST_IP}

echo
echo "EXECUTE ON MASTER: kubeadm token create --print-join-command --ttl 0"
echo "THEN RUN THE OUTPUT AS COMMAND HERE TO ADD AS WORKER"
echo
