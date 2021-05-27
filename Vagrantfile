Vagrant.configure("2") do |config|
  config.env.enable
  config.vm.box = ENV["BOX_IMAGE"]
  config.vm.box_version = ENV["KUBERNETES_VERSION"]
  config.vm.box_check_update = false
  config.vm.synced_folder ".data/", "/etc/.vagrantdata/"

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
      subconfig.vm.provision :shell do |s| 
        s.path = 'master.sh'
        s.env = { KUBE_VERSION:ENV['KUBE_VERSION'], NW_PLUGIN:ENV['NW_PLUGIN'], POD_NW_CIDR:ENV['POD_NW_CIDR'] }
      end
    end
  end
  if ENV["SETUP_NODES"]
    (1..( ENV["NODE_COUNT"] ).to_i(10)).each do |i|
      NODEHOSTNAME = ENV['NODE_HOSTNAME'] + "-#{i}"
      config.vm.define "#{NODEHOSTNAME}" do |subconfig|
        subconfig.vm.hostname = "#{NODEHOSTNAME}"
        subconfig.vm.network :private_network, ip: ENV["NODE_IP_NW"] + "#{i + 10}"
        subconfig.vm.provision :shell, path: 'worker.sh'
      end
    end
  end
end  

