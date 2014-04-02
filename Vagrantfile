# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

nodes = {
    'puppet'      => [05],
    'graphite'    => [10],
    'db0'         => [11],
    'gdash'       => [12],
    'packer'      => [13],
    'logstash'    => [14],
    'logclient'   => [15],
    'packer'      => [16],
    'controller0' => [20],
    'controller1' => [19],
    'client'      => ['dhcp'],
    'compute0'    => [25],
}

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "dcdevbox"
  nodes.each do |prefix, (ip)|
      hostname = "%s" % [prefix]
        config.vm.define "#{hostname}" do |box|
          box.vm.hostname = "#{hostname}.nick.datacentred.co.uk"
          if ip == 'dhcp'
            box.vm.network :private_network, type: :dhcp
          else
            box.vm.network :private_network, ip: "192.168.20.#{ip}", :netmask => "255.255.255.0"
          end
          # 'dcdevbox' has 512MB by default, so the below is in case we need to change that
          # VMware Fusion provider
          box.vm.provider :vmware_fusion do |v|
            case prefix
              when "puppet"
                v.vmx["memsize"] = 1024
              when "db0"
                v.vmx["memsize"] = 1024
              when "client"
                v.vmx["memsize"] = 256
              when "controller0"
                v.vmx["memsize"] = 1024
              when "controller1"
                v.vmx["memsize"] = 1024
            end
          end
          # Oracle VirtualBox provider
          box.vm.provider :virtualbox do |vbox|
            case prefix
              when "puppet"
                vbox.customize ["modifyvm", :id, "--memory", 1024]
              when "db0"
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
              "domain" => "nick.datacentred.co.uk",
              "is_vagrant" => "true",
            }
            puppet.options = "--verbose --debug --fileserverconfig=/vagrant/provision/puppet/fileserver.conf"
          end
        end
  end
end
