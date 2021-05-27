#!/bin/sh

kubeadm reset -f
rm -rf ~/.kube /etc/cni/net.d /etc/kubernetes /var/lib/etcd /var/lib/kubelet /var/run/kubernetes /var/lib/cni
iptables -F

HOST_IP=`/sbin/ifconfig eth1 | egrep -o 'inet [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'  | cut -d' ' -f2`
ip route add 10.96.0.0/16 dev eth1 src ${HOST_IP}

$(cat /etc/.vagrantdata/kubeadm-join)
