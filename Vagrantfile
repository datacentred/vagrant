# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

nodes = {
    'ns0'        => [10],
    'ns1'         => [11],
}

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "dcdevbox"
  nodes.each do |prefix, (ip)|
      hostname = "%s" % [prefix]
        config.vm.define "#{hostname}" do |box|
          box.vm.hostname = "#{hostname}.sal01.datacentred.co.uk"
          box.vm.network :private_network, ip: "192.168.20.#{ip}", :netmask => "255.255.255.0"
          # Configure virtual hardware - VMware Fusion provider
          box.vm.provider :vmware_fusion do |v|
            if prefix == "ns0"
              v.vmx["memsize"] = 512
            elsif prefix == "ns1"
              v.vmx["memsize"] = 256
            end
          end
          # And if we're using VirtualBox instead...
          box.vm.provider :virtualbox do |vbox|
            if prefix == "master"
              vbox.customize ["modifyvm", :id, "--memory", 512]
            elsif prefix == "slave"
              vbox.customize ["modifyvm", :id, "--memory", 256]
            end
          end
          config.vm.provision :puppet do |puppet|
            puppet.manifests_path = "provision"
            puppet.manifest_file = "#{hostname}.pp"
            puppet.module_path = "modules"
            puppet.hiera_config_path = "provision/puppet/hiera.yaml"
            puppet.facter = {
              "environment" => "development"
            }
            puppet.options = "--verbose --debug --fileserverconfig=/vagrant/provision/puppet/fileserver.conf"
          end
        end
  end
end
