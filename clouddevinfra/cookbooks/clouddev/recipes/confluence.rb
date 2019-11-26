#
# Cookbook Name:: confluence
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#


mounted = open('/proc/mounts') { |f| f.grep(/#{node[:confluence][:home]}/) }.length
# Do not execute if its already mounted

if mounted == 0

	aws_ebs_volume "confluence_home_data_volume" do
	  provider "aws_ebs_volume"
	  aws_access_key node[:runa][:aws_access_key]
	  aws_secret_access_key node[:runa][:aws_secret_access_key]
	  volume_id node[:runa][:volume_id]
	  availability_zone node[:runa][:availability_zone]
	  device node[:runa][:device]
	  action :attach
	end

	directory node[:confluence][:home] do
	  owner "confluence"
	  group "confluence"
	  mode "0755"
	  action :create
	end

	mount node[:confluence][:home] do
	  device node[:confluence][:device]
	  options "rw noatime"
	  fstype "xfs"
	  action [ :enable, :mount ]
	end
end

cookbook_file "/var/atlassian/application-data/confluence/confluence.cfg.xml" do
   source "confluence/conf-config.xml"
   owner "confluence"
   action :create
end

service "confluence" do
 provider Chef::Provider::Service::Init
 action [ :start ]
end

cookbook_file "/etc/nginx/sites-enabled/confluence" do
   source "confluence/nginx-config.txt"
   action :create
end




service "nginx" do
 action :restart
end

aws_elastic_lb "ELB_Crowd" do
	  aws_access_key node[:runa][:aws_access_key]
	  aws_secret_access_key node[:runa][:aws_secret_access_key]
	  name "CloudInfDev-Confluence"
	  action :register
end
