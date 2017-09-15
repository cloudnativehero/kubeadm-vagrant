# -*- mode: ruby -*-
# vi: set ft=ruby :

# Install a kube cluster using kubeadm:
# http://kubernetes.io/docs/getting-started-guides/kubeadm/

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"
  config.vm.box_check_update = false

  config.vm.provision :shell, :path => "install.sh"

  config.hostmanager.enabled = true
  config.hostmanager.manage_guest = true

  # config.vm.network "forwarded_port", guest: 80, host: 8080
  # config.vm.network "private_network", ip: "192.168.77.10"

  # config.vm.network "public_network"

  config.vm.provider "virtualbox" do |vb|
    vb.cpus = 2
    vb.memory = "1024"
  end

  config.vm.define "n1" do |c|
      c.vm.hostname = "n1"
      c.vm.network "private_network", ip: "192.168.77.10"
      # Run the following (2/4):
      # kubeadm init --api-advertise-addresses=192.168.77.10
      # After nodes are joined (4/4):
      # kubectl apply -f https://git.io/weave-kube
  end

  config.vm.define "n2" do |c|
      c.vm.hostname = "n2"
      c.vm.network "private_network", ip: "192.168.77.11"
      # After master is ready (3/4):
      # kubeadm join --token <token> <master-ip>
  end

  config.vm.define "n3" do |c|
      c.vm.hostname = "n3"
      c.vm.network "private_network", ip: "192.168.77.12"
  end

end
