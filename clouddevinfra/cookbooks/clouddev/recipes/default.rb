#
# Cookbook Name:: clouddev
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe "apt"

apt_repository "newrelic" do
  uri "http://apt.newrelic.com/debian/"
  key "http://download.newrelic.com/548C16BF.gpg"
  distribution "newrelic"
  components ["non-free"]
  action :add
end

# install new-relic monitoring
if node[:newrelic]
  package "newrelic-sysmond"
  
  execute "new_relic_config" do
    command "nrsysmond-config --set license_key=#{node[:newrelic][:license_key]}"
    user "root"
  end

  service "newrelic-sysmond" do
    action [:enable,:start]
  end 
end

package "nginx"
package "unzip"

package "postfix" do
  action :install
end

service "postfix" do
  action [:enable,:start]
end

remote_directory "/usr/share/nginx/www/" do
  source "html_index"
  files_owner "ubuntu"
  files_owner "ubuntu"
  mode "0755"
  action [:create]
end

# install jdk6 from Oracle
#java_ark "jdk" do
 #   url 'http://s3.amazon.com/chef-clouddevinfra/installers/jdk-6u32-linux-x64.bin'
  #  app_home '/opt/java'
   # bin_cmds ["java", "javac"]
   # action :install
#end

cookbook_file "/etc/default/environment" do
   source "env/environment.properties"
   action :create
end
