#!/bin/sh

# Source: http://kubernetes.io/docs/getting-started-guides/kubeadm/

apt-get erase -y docker.io kubelet kubeadm kubectl kubernetes-cni
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF > /etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y docker.io kubelet kubeadm kubectl kubernetes-cni
systemctl enable kubelet && systemctl start kubelet
systemctl enable docker && systemctl start docker

CGROUP_DRIVER=$(sudo docker info | grep "Cgroup Driver" | awk '{print $3}')

sed -i "s|KUBELET_KUBECONFIG_ARGS=|KUBELET_KUBECONFIG_ARGS=--cgroup-driver=$CGROUP_DRIVER |g" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

sed -i 's/10.96.0.10/10.3.3.10/g' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

systemctl daemon-reload

systemctl stop kubelet && systemctl start kubelet
