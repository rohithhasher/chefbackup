#
# Cookbook Name:: csvnrepo
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

## Mount svn repositories volume
svnrepo_mounted = open('/proc/mounts') { |f| f.grep(/#{node[:svn][:svnrepo]}/) }.length
# Do not execute if its already mounted
if svnrepo_mounted == 0

	aws_ebs_volume "attach_svn_repo_ebs_volume" do
	  provider "aws_ebs_volume"
	  aws_access_key node[:runa][:aws_access_key]
	  aws_secret_access_key node[:runa][:aws_secret_access_key]
	  volume_id node[:runa][:svnrepo][:volume_id]
	  availability_zone node[:runa][:availability_zone]
	  device node[:runa][:svnrepo][:device_aws]
	  action :attach
	end

	directory node[:svn][:svnrepo] do
	  owner "ubuntu"
	  group "ubuntu"
	  mode "0755"
	  action :create
	end

	mount node[:svn][:svnrepo] do
	  device node[:runa][:svnrepo][:device_sys]
	  options "rw noatime"
	  fstype "xfs"
	  action [ :enable, :mount ]
	end
end

aws_elastic_lb "ELB_SVN" do
  aws_access_key node[:runa][:aws_access_key]
  aws_secret_access_key node[:runa][:aws_secret_access_key]
  name "CloudInfDev-SVN"
  action :register
end

execute "csvn_start" do
  command "/opt/csvn/bin/csvn-httpd restart"
  user "ubuntu"
end

