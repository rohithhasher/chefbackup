#include_recipe "apt"
#include_recipe "java"

apt_repository "jenkins" do
  uri "http://pkg.jenkins-ci.org/debian"
  key "http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key"
  components ["binary/"]
  action :add
end

package "jenkins"

package "maven2"

mounted = open('/proc/mounts') { |f| f.grep(/mnt\/jenkins/) }.length

# Do not execute if its already mounted
if mounted == 0

  aws_ebs_volume "jenkins_home_data_volume" do
      provider "aws_ebs_volume"
      aws_access_key node[:runa][:aws_access_key]
      aws_secret_access_key node[:runa][:aws_secret_access_key]
      volume_id "vol-1855cb62"
      availability_zone "us-east-1a"
      ignore_failure true # Its Okay if the volume is already detached 
      action :detach
  end

  aws_ebs_volume "jenkins_home_data_volume" do
    provider "aws_ebs_volume"
    aws_access_key node[:runa][:aws_access_key]
    aws_secret_access_key node[:runa][:aws_secret_access_key]
    volume_id "vol-1855cb62"
    availability_zone "us-east-1a"
    device "/dev/sdh"
    action :attach
  end

  directory "/mnt/jenkins" do
    owner "jenkins"
    group "ubuntu"
    mode "0755"
    action :create
    recursive true
    not_if { File.exists?("/mnt/jenkins") }
  end
  
  # Assumption is that filesystem is already formatted
  mount "/mnt/jenkins" do
    device "/dev/xvdh"
    options "rw noatime"
    fstype "xfs"
    action [ :enable, :mount ]
  end
end

%w{jobs workspace}.each do |dir|
  
  directory "/var/lib/jenkins/#{dir}" do
    action :delete
    not_if "test -L /var/lib/jenkins/#{dir}"
  end
    
  link "/var/lib/jenkins/#{dir}" do
    to "/mnt/jenkins/#{dir}"
    owner "jenkins"
  end
end

cookbook_file "/etc/default/jenkins" do
   source "jenkins/jenkins.config.properties"
   owner "jenkins"
   action :create
   notifies :restart, "service[jenkins]"
end

service "jenkins" do
  supports [:stop, :start, :restart]
  action [:start, :enable]
end

template "/etc/nginx/sites-enabled/jenkins" do
   source "proxy_server.erb"
   variables(
    :server_name => "ci.devcloud.hma.com",
    :server_port => "8080"
   )
   notifies :restart, "service[nginx]"
end

service "nginx" do
  supports [:stop, :start, :restart]
  action [:enable,:start]
end

aws_elastic_lb "ELB_Jira" do
    aws_access_key node[:runa][:aws_access_key]
    aws_secret_access_key node[:runa][:aws_secret_access_key]
    name "CloudInfDev-Jenkins"
    action :register
end
