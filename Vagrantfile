Vagrant.configure("2") do |config|
  config.env.enable
  config.vm.box = ENV["BOX_IMAGE"]
  config.vm.box_version = ENV["KUBERNETES_VERSION"]
  config.vm.box_check_update = false

  config.vm.provider ENV["PROVIDER"] do |l|
    l.cpus = ENV["NODE_CPU"]
    l.memory = ENV["NODE_MEMORY"]
  end

  config.hostmanager.enabled = true
  config.hostmanager.manage_guest = true
  # config.vm.network "public_network"

  if ENV["SETUP_MASTER"]
    config.vm.define ENV["MASTER_HOSTNAME"] do |subconfig|
      subconfig.vm.hostname = ENV["MASTER_HOSTNAME"]
      subconfig.vm.network :private_network, ip: ENV["MASTER_IP"]
      subconfig.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--cpus", ENV["MASTER_CPU"]]
        vb.customize ["modifyvm", :id, "--memory", ENV["MASTER_MEMORY"]]
      end
      subconfig.vm.provision :shell, inline: $kubemasterscript
    end
  end
  if ENV["SETUP_NODES"]
    (1..( ENV["NODE_COUNT"] ).to_i(10)).each do |i|
      NODEHOSTNAME = ENV['NODE_HOSTNAME'] + "-#{i}"
      config.vm.define "#{NODEHOSTNAME}" do |subconfig|
        subconfig.vm.hostname = "#{NODEHOSTNAME}"
        subconfig.vm.network :private_network, ip: ENV["NODE_IP_NW"] + "#{i + 10}"
        subconfig.vm.provision :shell, inline: $kubeworkerscript
      end
    end
  end
end  

$kubeworkerscript = <<WSCRIPT
HOST_IP=`/sbin/ifconfig eth1 | egrep -o 'inet [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'  | cut -d' ' -f2`
ip route add 10.96.0.0/16 dev eth1 src ${HOST_IP}

echo
echo "EXECUTE ON MASTER: kubeadm token create --print-join-command --ttl 0"
echo "THEN RUN THE OUTPUT AS COMMAND HERE TO ADD AS WORKER"
echo

WSCRIPT

$kubemasterscript = <<SCRIPT

HOST_IP=`/sbin/ifconfig eth1 | egrep -o 'inet [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'  | cut -d' ' -f2`
ip route add 10.96.0.0/16 dev eth1 src ${HOST_IP}

### init k8s
kubeadm init --apiserver-advertise-address=${HOST_IP} --kubernetes-version=#{ENV['KUBERNETES_VERSION']} --pod-network-cidr=#{ENV['POD_NW_CIDR']} --skip-token-print

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl taint nodes --all node-role.kubernetes.io/master-
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

SCRIPT
