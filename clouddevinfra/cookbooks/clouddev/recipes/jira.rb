#
# Cookbook Name:: jira
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#


mounted = open('/proc/mounts') { |f| f.grep(/#{node[:jira][:home]}/) }.length

# Do not execute if its already mounted
if mounted == 0

	aws_ebs_volume "jira_home_data_volume" do
	  provider "aws_ebs_volume"
	  aws_access_key node[:runa][:aws_access_key]
	  aws_secret_access_key node[:runa][:aws_secret_access_key]
	  volume_id node[:runa][:volume_id]
	  availability_zone node[:runa][:availability_zone]
	  device node[:runa][:device]
	  action :attach
	end

	directory node[:jira][:home] do
	  owner "jira"
	  group "jira"
	  mode "0755"
	  action :create
	end

	mount node[:jira][:home] do
	  device node[:jira][:device]
	  options "rw noatime"
	  fstype "xfs"
	  action [ :enable, :mount ]
	end
	
end

cookbook_file "/var/atlassian/application-data/jira/dbconfig.xml" do
   source "jira/jira-db-config.xml"
   owner "jira"
   group "jira"
   action :create
end

service "jira" do
 provider Chef::Provider::Service::Init
 action :start
end

cookbook_file "/etc/nginx/sites-enabled/jira" do
   source "jira/nginx-config.txt"
   action :create
end

service "nginx" do
 action :restart
end

aws_elastic_lb "ELB_Jira" do
	  aws_access_key node[:runa][:aws_access_key]
	  aws_secret_access_key node[:runa][:aws_secret_access_key]
	  name "CloudInfDev-Jira"
	  action :register
end
