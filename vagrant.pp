# Generic template for provisioning a VM via Vagrant and puppet
# Include these modules
include apt
include dc_profile::dns-master

# Example of how to insert a file
file { 'test.txt':
  name          => '/var/tmp/test.txt',
  ensure        => present,
  source        => 'puppet:///vagrant/test.txt',
  owner         => root,
  group         => root,
  mode          => 0640,
}
