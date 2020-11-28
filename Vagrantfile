# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
      config.vm.define "node-1" do |node|
          node.vm.box = "ubuntu/focal64"
          node.vm.hostname = "node-1"
          # Bridged network
          node.vm.network "public_network", bridge: "en0: Wi-Fi (AirPort)", ip:"192.168.1.111"
          # Provider-specific configuration
          node.vm.provider "virtualbox" do |vb|
              # Customize the amount of memory on the VM
              vb.memory = "2048"
              # Specify machine name
              vb.name = "node-1"
          end
      end

      config.vm.provision "file", source: "~/.ssh/id_rsa.pub", destination: "/home/vagrant/.ssh/id_rsa.pub"
      config.vm.provision :shell, :inline => "cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys", run: "always"
end