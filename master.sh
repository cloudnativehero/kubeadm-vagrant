#!/bin/sh
# Use this script to initialize master

kubeadm reset -f
rm -rf ~/.kube /etc/cni/net.d /etc/kubernetes /var/lib/etcd /var/lib/kubelet /var/run/kubernetes /var/lib/cni /opt/cni
iptables -F

HOST_IP=`/sbin/ifconfig eth1 | egrep -o 'inet [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'  | cut -d' ' -f2`
ip route add 10.96.0.0/16 dev eth1 src ${HOST_IP}

### init k8s
kubeadm init --apiserver-advertise-address=${HOST_IP} --kubernetes-version=${KUBE_VERSION} --pod-network-cidr=${POD_NW_CIDR} --skip-token-print

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

cp -R $HOME/.kube /vagrant/

kubectl taint nodes --all node-role.kubernetes.io/master-
case $NW_PLUGIN in
  "weave" ) kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')" ;;
  "calico" ) kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml ;;
  *) echo "Running default with calico" && kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml ;;
esac
kubeadm token create --print-join-command --ttl 0 > /etc/.vagrantdata/kubeadm-join