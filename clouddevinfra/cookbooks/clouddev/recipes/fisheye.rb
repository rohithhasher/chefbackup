

template "/etc/nginx/sites-enabled/fisheye" do
   source "proxy_server.erb"
   variables(
    :server_name => "code.devcloud.hma.com",
    :server_port => "8060"
   )
   notifies :restart, "service[nginx]"
end

mounted = open('/proc/mounts') { |f| f.grep(/mnt\/fisheye/) }.length

# Do not execute if its already mounted
if mounted == 0

  aws_ebs_volume "fisheye_volume" do
      provider "aws_ebs_volume"
      aws_access_key node[:runa][:aws_access_key]
      aws_secret_access_key node[:runa][:aws_secret_access_key]
      volume_id "vol-7ac47e00"
      availability_zone "us-east-1a"
      ignore_failure true # Its Okay if the volume is already detached 
      action :detach
  end
    
  aws_ebs_volume "fisheye_volume" do
    provider "aws_ebs_volume"
    aws_access_key node[:runa][:aws_access_key]
    aws_secret_access_key node[:runa][:aws_secret_access_key]
    volume_id "vol-7ac47e00"
    availability_zone "us-east-1a"
    device "/dev/sdh"
    action :attach
  end

  directory "/mnt/fisheye" do
      owner "ubuntu"
      group "ubuntu"
      mode "0755"
      action :create
      not_if { File.exists?("/mnt/fisheye") }
  end
  
  mount "/mnt/fisheye" do
    device "/dev/xvdh"
    options "rw noatime"
    fstype "xfs"
    action [ :enable, :mount ]
  end
  
end

directory "/mnt/fisheye/managed-repo" do
    owner "ubuntu"
    group "ubuntu"
    mode "0755"
    action :create
    not_if { File.exists?("/mnt/fisheye/managed-repo") }
end

package "unzip"

script "install_crucible" do
  interpreter "bash"
  user "root"
  cwd "/tmp"
  code <<-EOH
  wget http://s3.amazonaws.com/clouddevinfra/installers/crucible-2.8.1.zip
  unzip crucible-2.8.1.zip -d /opt/fisheye
  chown -R ubuntu:ubuntu /opt/fisheye
  EOH
  not_if { File.exists?("/opt/fisheye") } 
end

directory "/var/fisheye-home" do
    owner "ubuntu"
    group "ubuntu"
    mode "0755"
    action :create
    not_if { File.exists?("/var/fisheye-home") }
end

cookbook_file "/var/fisheye-home/config.xml" do
   source "fisheye/config.xml"
   action :create
end

# Patch Fisheye to Use IPV4

cookbook_file "/opt/fisheye/fecru-2.8.1/bin/fisheyectl.sh" do
   source "fisheye/fisheyectl.sh"
   mode "0755"
   action :create
end

execute "start_fisheye" do
  command "/opt/fisheye/fecru-2.8.1/bin/fisheyectl.sh start"
  action :run
  environment ({'FISHEYE_INST' => '/var/fisheye-home'})
end

# Mount volume to 
# Setup Backup for /var/fisheye-home/
# FISHEYE_INST=/var/fisheye-home
# JAVA_HOME=/var/fisheye-home

service "nginx" do
  supports [:stop, :start, :restart]
  action [:enable,:start]
end

aws_elastic_lb "ELB_Jira" do
    aws_access_key node[:runa][:aws_access_key]
    aws_secret_access_key node[:runa][:aws_secret_access_key]
    name "CloudInfDev-Code"
    action :register
end
