# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

nodes = {
    'graphite'  => [10],
    'db0'       => [11],
    'gdash'     => [12],
    'packer'    => [13],
    'logstash'  => [14],
    'logclient' => [15],
    'packer'    => [16],
    'client'    => ['dhcp'],
}

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "dcdevbox"
  nodes.each do |prefix, (ip)|
      hostname = "%s" % [prefix]
        config.vm.define "#{hostname}" do |box|
          box.vm.hostname = "#{hostname}.sal01.datacentred.co.uk"
          if ip == 'dhcp'
            box.vm.network :private_network, type: :dhcp
          else
            box.vm.network :private_network, ip: "192.168.20.#{ip}", :netmask => "255.255.255.0"
          end
          # Configure virtual hardware - VMware Fusion provider
          box.vm.provider :vmware_fusion do |v|
            if prefix == "graphite"
              v.vmx["memsize"] = 512
            elsif prefix == "db0"
              v.vmx["memsize"] = 256
            end
          end
          # Or if we're using VirtualBox instead...
          box.vm.provider :virtualbox do |vbox|
            if prefix == "graphite"
              vbox.customize ["modifyvm", :id, "--memory", 512]
            elsif prefix == "db0"
              vbox.customize ["modifyvm", :id, "--memory", 256]
            end
          end
          # Conditionally forward various ports for certain hosts
          # Graphite
          if prefix == "graphite"
            config.vm.network "forwarded_port", guest: 80, host: 8080
            config.vm.network "forwarded_port", guest: 8080, host: 9090 
            config.vm.network "forwarded_port", guest: 9292, host: 9292
            config.vm.network "forwarded_port", guest: 5672, host: 5672
          end
          # Logstash / Kibana
          if prefix == "logstash"
            config.vm.network "forwarded_port", guest: 80, host: 8081
            config.vm.network "forwarded_port", guest: 9200, host: 9200
          end
          # Provisioning via puppet.  This expects a manifest in a subdirectory called 'provision'
          # with the same filename as the host defined in the 'nodes' section above.
          config.vm.provision :puppet do |puppet|
            puppet.manifests_path = "provision"
            puppet.manifest_file = "#{hostname}.pp"
            puppet.module_path = "modules"
            puppet.hiera_config_path = "provision/puppet/hiera.yaml"
            puppet.facter = {
              "environment" => "production",
            }
            puppet.options = "--verbose --debug --fileserverconfig=/vagrant/provision/puppet/fileserver.conf"
          end
        end
  end
end
