# kubeadm-vagrant
Setup Kubernetes Cluster with Kubeadm and Vagrant

Introduction

With reference to steps listed at [Using kubeadm to Create a Cluster](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/) for setting up the Kubernetes cluster with kubeadm. I have been working on an automation to setup the cluster. The result of it is [kubeadm-vagrant](https://github.com/coolsvap/kubeadm-vagrant), a github project with simple steps to setup your kubernetes cluster with more control on vagrant based virtual machines.

Installation

- Clone the kubeadm-vagrant repo

```git clone https://github.com/coolsvap/kubeadm-vagrant ```

- Choose your distribution of choice from CentOS/Ubuntu and move to the specific directory.
- Configure the cluster parameters in Vagrantfile. Refer below for details of configuration options.

``` vi Vagrantfile ```

- Spin up the cluster

``` vagrant up ```

- This will spin up new Kubernetes cluster. You can check the status of cluster with following command,

```
sudo su
kubectl get pods --all-namespaces

```
Cluster Configuration Options

1. You need to generate a KUBETOKEN of your choice to be used while creating the cluster. You will need to install kubeadm package on your host to create the token with following command

```
# kubeadm token generate 
148a37.736fd53655b767b7

```
1. ``` BOX_IMAGE ``` is currently default with &quot;coolsvap/centos-k8s&quot; box which is custom box created which can be used for setting up the cluster with basic dependencies for kubernetes node.
2. Set ``` SETUP_MASTER ``` to true if you want to setup the node. This is true by default for spawning a new cluster. You can skip it for adding new minions.
3. Set ``` SETUP_NODES ``` to true/false depending on whether you are setting up minions in the cluster.
4. Specify ``` NODE_COUNT ``` as the count of minions in the cluster
5. Specify  the ``` MASTER_IP ``` as static IP which can be referenced for other cluster configurations
6. Specify ``` NODE_IP_NW ``` as the network IP which can be used for assigning dynamic IPs for cluster nodes from the same network as Master
7. Specify custom ``` POD_NW_CIDR ``` of your choice
8. Setting up kubernetes dashboard is still a WIP with ``` K8S_DASHBOARD ``` option.
