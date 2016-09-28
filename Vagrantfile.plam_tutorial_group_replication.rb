# -*- mode: ruby -*-
# vi: set ft=ruby :

# Assumes a box from https://github.com/grypyrg/packer-percona

# HOW TO USE
# You have to bring the machines up prior to provisioning. so run it in 2 steps:
#
# # vagrant up --no-provision --parallel
# # vagrant provision --parallel


if_adapter='vboxnet1'
ip_range='192.168.56.1'
prefix='plam-'

nodes = {
  prefix + 'mysql1' => {
    'local_vm_ip'       => ip_range + '1',
    'server_id'         => 1
  },
  prefix + 'mysql2' => {
    'local_vm_ip'       => ip_range + '2',
    'server_id'         => 2
  },
  prefix + 'mysql3' => {
    'local_vm_ip'       => ip_range + '3',
    'server_id'         => 3
  },
  prefix + 'mysql4' => {
    'local_vm_ip'       => ip_range + '4',
    'server_id'         => 4
  }
}


require File.dirname(__FILE__) + '/lib/vagrant-common.rb'

# make a comma separated serverlist, which can be reused in puppet
serverlist=nodes.map{|k,v| '#{k}'}.join(',')

# should we use the public or private ips when using AWS
hostmanager_aws_ips='private'


Vagrant.configure('2') do |config|
  #config.vm.box = 'grypyrg/centos-x86_64'
  config.vm.box = 'lefred14/centos7_64'
  config.ssh.username = 'vagrant'

  # it's disabled by default, it's done during the provision phase
  config.hostmanager.enabled = false
  config.hostmanager.include_offline = true

  # Create all three nodes identically except for name and ip
  nodes.each_pair { |name, node_params|
    config.vm.boot_timeout = 600
    config.vm.define name do |node_config|
      node_config.vm.hostname = name
      node_config.vm.network :private_network, ip: node_params['local_vm_ip'], adaptor: if_adapter

      ssh_port = '882' + node_params['server_id'].to_s
      node_config.vm.network 'forwarded_port', guest: 22, host: ssh_port, auto_correct: false

      # Provisioners
      node_config.vm.provision :hostmanager

      provider_virtualbox( nil, node_config, 256)

      # run ansible when last host is up
      if name == prefix + 'mysql4'
        config.vm.provision "ansible" do |ansible|
          ansible.limit = "all"
          ansible.playbook = "playbooks/plam_tutorial_group_replication.yml"
          ansible.verbose = false
          ansible.extra_vars = {
            first_node:         prefix + 'mysql1',
            async_repl_nodes:   prefix + 'mysql1' + ',' + prefix + 'mysql2',
            async_repl_master:  prefix + 'mysql1',
            async_repl_slave:   prefix + 'mysql2'
          }
          ansible.host_vars = {
            prefix + 'mysql1' => {
              "server_id"         => nodes[prefix + 'mysql1']['server_id']
            },
            prefix + 'mysql2' => {
              "server_id"         => nodes[prefix + 'mysql2']['server_id']
            },
            prefix + 'mysql3' => {
              "server_id"         => nodes[prefix + 'mysql3']['server_id']
            },
            prefix + 'mysql4' => {
              "server_id"         => nodes[prefix + 'mysql4']['server_id']
            },
          }
        end
      end

    end
  }
end

