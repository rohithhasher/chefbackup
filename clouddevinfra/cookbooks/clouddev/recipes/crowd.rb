#
# Cookbook Name:: jira
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#


cookbook_file "/var/crowd-home/crowd.properties" do
   source "crowd/crowd.properties"
   owner "ubuntu"
   action :create
end

cookbook_file "/var/crowd-home/crowd.cfg.xml" do
   source "crowd/crowd.cfg.xml"
   owner "ubuntu"
   action :create
end

service "crowd" do
 provider Chef::Provider::Service::Init
 action [ :start ]
end

cookbook_file "/etc/nginx/sites-enabled/crowd" do
   source "crowd/nginx-config.txt"
   action :create
end

service "nginx" do
 action :restart
end

## Not working right now. Has to be a manual step
## aws_elastic_lb "ELB_Crowd" do
## 	  aws_access_key node[:runa][:aws_access_key]
## 	  aws_secret_access_key node[:runa][:aws_secret_access_key]
## 	  name "CloudInfDev-Crowd"
## 	  action :register
## end
