script "install_sonar" do
  interpreter "bash"
  user "root"
  cwd "/tmp"
  code <<-EOH
  wget http://dist.sonar.codehaus.org/sonar-3.2.1.zip
  unzip sonar-3.2.1.zip -d /opt/sonar
  chown -R ubuntu:ubuntu /opt/sonar
  EOH
  not_if { File.exists?("/opt/sonar") } 
end

sonar_home = "/opt/sonar/sonar-3.2.1"

cookbook_file "#{sonar_home}/conf/sonar.properties" do
   source "sonar/sonar.properties"
   owner "ubuntu"
   action :create
end

template "/etc/nginx/sites-enabled/sonar" do
   source "proxy_server.erb"
   variables(
    :server_name => "metrics.devcloud.hma.com",
    :server_port => "9000"
   )
   notifies :restart, "service[nginx]"
end

service "nginx" do
  supports [:stop, :start, :restart]
  action [:enable,:start]
end
aws_elastic_lb "ELB_Sonar" do
    aws_access_key node[:runa][:aws_access_key]
    aws_secret_access_key node[:runa][:aws_secret_access_key]
    name "CloudInfDev-Sonar"
    action :register
end

script "install_sonar_plugin" do
  interpreter "bash"
  user "root"
  cwd "/tmp"
  code <<-EOH
  wget http://repository.codehaus.org/org/codehaus/sonar-plugins/sonar-crowd-plugin/1.0/sonar-crowd-plugin-1.0.jar
  mv sonar-crowd-plugin-1.0.jar /opt/sonar/sonar-3.2.1/extensions/plugins
  chown -R ubuntu:ubuntu /opt/sonar/sonar-3.2.1/extensions/plugins
  EOH
  not_if { File.exists?("/opt/sonar/sonar-3.2.1/extensions/plugins") }
end

execute "sonar_start" do
  command "#{sonar_home}/bin/linux-x86-64/sonar.sh restart"
  user "ubuntu"
end
