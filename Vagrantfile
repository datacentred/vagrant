# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

nodes = {
    'ns0'        => [10],
    'ns1'         => [11],
    'logstash'    => [20],
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

          # Conditionally forward various ports for certain hosts
          if prefix == "logstash" # useful stuff for logstash
            config.vm.network "forwarded_port", guest: 8080, host: 8080 # kibana
            config.vm.network "forwarded_port", guest: 9292, host: 9292 # logstash default web
            config.vm.network "forwarded_port", guest: 5672, host: 5672 # rabbitmq
            config.vm.network "forwarded_port", guest: 9200, host: 9200 # elasticsearch
          end

          # Provisioning via puppet.  This expects a manifest in a subdirectory called 'provision'
          # with the same filename as the host defined in the 'nodes' section above.
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
