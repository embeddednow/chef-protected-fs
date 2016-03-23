#
# Cookbook Name:: protected-fs
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

include_recipe 'apt'

# SETUP
grub_config = File.read('/boot/grub/grub.cfg')
matches = grub_config.match(/^\tlinux\s+\/boot\/vmlinuz-(?<version>.*)-generic.*$/)
version_str = matches['version']

# INSTALL OVERLAYROOT

package 'overlayroot' do
  action :install
end

cookbook_file '/etc/overlayroot.conf' do
  source 'overlayroot.conf'
  group  'root'
  owner  'root'
  mode   '0644'
  action :create
end

# CONFIGURE GRUB

boot_disk = node['grub']['boot_disk']

execute 'update-grub' do
  command 'update-grub'
  action  :nothing
end

cookbook_file '/etc/default/grub' do
  source   'grub'
  group    'root'
  user     'root'
  mode     '0755'
  action   :create
  notifies :run, 'execute[update-grub]', :immediately
end

template '/etc/grub.d/40_custom' do
  source    '40_custom.erb'
  group     'root'
  user      'root'
  mode      '0755'
  variables {
              disk_uuid: node['filesystem'][boot_disk]['uuid'],
              version: version_str
            }
  action    :create
  notifies  :run, 'execute[update-grub]', :immediately
end

