NODE_COUNT = 1

Vagrant.configure("2") do |config|
  config.env.enable
  config.vm.box = ENV["BOX_IMAGE"]
  config.vm.box_check_update = false

  config.vm.provider "virtualbox" do |l|
    l.cpus = 1
    l.memory = "2048"
  end

  config.vm.provision :shell, :path => "install-node.sh"

  config.hostmanager.enabled = true
  config.hostmanager.manage_guest = true
  # config.vm.network "public_network"

  if ENV["SETUP_MASTER"]
    config.vm.define "master" do |subconfig|
      subconfig.vm.hostname = "master"
      subconfig.vm.network :private_network, ip: ENV["MASTER_IP"]
      subconfig.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--cpus", "2"]
        vb.customize ["modifyvm", :id, "--memory", "4096"]
      end
      subconfig.vm.provision :shell, inline: $kubemasterscript, args: [ENV["KUBE_VERSION"], ENV["POD_NW_CIDR"]]
    end
  end

  if ENV["SETUP_NODES"]
    (1..NODE_COUNT).each do |i|
      config.vm.define "node#{i}" do |subconfig|
        subconfig.vm.hostname = "node#{i}"
        subconfig.vm.network :private_network, ip: ENV["NODE_IP_NW"] + "#{i + 10}"
        subconfig.vm.provision :shell, inline: $kubeworkerscript
      end
    end
  end
end  

$kubeworkerscript = <<WSCRIPT

echo
echo "EXECUTE ON MASTER: kubeadm token create --print-join-command --ttl 0"
echo "THEN RUN THE OUTPUT AS COMMAND HERE TO ADD AS WORKER"
echo

WSCRIPT

$kubemasterscript = <<SCRIPT

#Pull images
kubeadm config images pull

HOST_IP=`/sbin/ifconfig eth1 | egrep -o 'inet [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'  | cut -d' ' -f2`
### init k8s
kubeadm init --apiserver-advertise-address=${HOST_IP} --kubernetes-version=$1 --pod-network-cidr=$2 --skip-token-print

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl taint nodes --all node-role.kubernetes.io/master-

kubectl create -f https://docs.projectcalico.org/manifests/tigera-operator.yaml
kubectl create -f https://docs.projectcalico.org/manifests/custom-resources.yaml

SCRIPT
