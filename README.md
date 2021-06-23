# Setup Kubernetes Cluster with Kubeadm and Vagrant

## Introduction

With reference to steps listed at [Using kubeadm to Create a Cluster](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/) for setting up the Kubernetes cluster with kubeadm. I have been working on an automation to setup the cluster. The result of it is [kubeadm-vagrant](https://github.com/cloudnative-tech/kubeadm-vagrant), a github project with simple steps to setup your kubernetes cluster with more control on vagrant based virtual machines.

### Installation
- Download and install [Vagrant](https://www.vagrantup.com/) specific to your OS 

- Install few Vagrant plugins required for setting it up.

```
vagrant plugin install vagrant-hostmanager
vagrant plugin install vagrant-hosts
vagrant plugin install vagrant-env
```

- Clone the [kubeadm-vagrant](https://github.com/cloudnative-tech/kubeadm-vagrant) repo

``` git clone https://github.com/cloudnative-tech/kubeadm-vagrant ```

- For setting up up the Nodes configure the cluster parameters in ```.env``` file. Refer section below for details of configuration options.

``` vi .env ```
- Create a directory to store artifacts created during cluster creation.

``` mkdir .data```

- Spin up the cluster

``` vagrant up ```

- This will spin up new Kubernetes cluster. You can check the status of cluster with following command,
  - For Master Node
    ```
    vagrant ssh k8s-master
    sudo su
    kubectl get pods --all-namespaces
    ```
  - For Worker Node
    ```
    vagrant ssh k8s-node-<NodeNumber>
    ```
Cluster Configuration Options

1. Generic Properties 
- ``` BOX_IMAGE ``` is currently default with &quot;generic/ubuntu1804&quot; box which is custom box created which can be used for setting up the cluster with basic dependencies for kubernetes node.
- ``` PROVIDER ``` is currently default with &quot;virtualbox&quot; It may change in future with more providers.
- ``` KUBE_VERSION ``` is the version of Kubernetes cluster you want to set up with. The main branch will always have the latest available versions. You can find older versions in the releases.
- ``` NW_PLUGIN ``` is the network plugin you wish to enable with the Kubernetes cluster. Currently it supports ```calico``` an ```weave```
- A secure dashboard is enabled by default. To enable ```INSECURE_DASHBOARD``` can be used. Set its value to ```yes```
  - You can login to dashboard using ```https://<MASTER_IP>:31443``` and the ```.kube/config``` file from your vagrant directory.
- A Load Balancer IP Pool can be provided with ```LB_IPPOOL```. The format is the range of IP addresses in your host-only network.
- The sandbox by default will install HELM v 3.x. To disable it, update ```INSTALL_HELM``` to ```no```
- The sandbox by default will enable [operator-sdk](https://sdk.operatorframework.io/docs/overview/) and OLM. To disable it, update ```ENABLE_OLM``` to ```no```

2. Master Node Properties 
- Set ``` SETUP_MASTER ``` to true if you want to setup the node. This is true by default for spawning a new cluster. You can skip it for adding new worker nodes.
- Set ```MASTER_IP``` to a preferred value from the subnet of your virtualbox host-only network. 
- Specify custom ``` POD_NW_CIDR ``` of your choice for particular ```NW_PLUGIN```
- Specify Master node hostname with ```MASTER_HOSTNAME```
- Provide your recommended values for ```MASTER_CPU``` AND ```MASTER_MEMORY```. The minimum values for both are 2 and 2048 respectively.

3. Worker Noder Properties
- Set ``` SETUP_NODES ``` to true/false depending on whether you are setting up worker nodes in the cluster.
- Specify ``` NODE_COUNT ``` as the count of worker nodes in the cluster
- Specify ``` NODE_IP_NW ``` as the network IP which can be used for assigning dynamic IPs for cluster nodes from the same network as Master
- Specify Worker node hostname with ```NODE_HOSTNAME```
- Provide your recommended values for ```NODE_CPU``` AND ```NODE_MEMORY```. The minimum values for both are 1 and 1024 respectively.
