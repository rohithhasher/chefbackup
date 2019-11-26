script "install_csvn" do
  interpreter "bash"
  user "root"
  cwd "/tmp"
  code <<-EOH
  wget https://s3.amazonaws.com/clouddevinfra/installers/CollabNetSubversionEdge-3.1.0_linux-x86_64.tar.gz
  tar -zxvf CollabNetSubversionEdge-3.1.0_linux-x86_64.tar.gz -C /opt/
  chown -R ubuntu:ubuntu /opt/csvn
  EOH
  not_if { File.exists?("/opt/csvn") } 
end

script "get_crowd_plugins" do
  interpreter "bash"
  user "root"
  cwd "/tmp"
  code <<-EOH
  wget https://s3.amazonaws.com/clouddevinfra/installers/mod_authnz_crowd.so
  wget https://s3.amazonaws.com/clouddevinfra/installers/mod_authz_svn_crowd.so
  cp mod_auth*_crowd.so /opt/csvn/lib/modules
  chown -R ubuntu:ubuntu /opt/csvn/lib/modules/mod_auth*_crowd.so
  chmod a+x /opt/csvn/lib/modules/mod_auth*_crowd.so
  EOH
  not_if { File.exists?("/opt/csvn/lib/modules/mod_auth*_crowd.so") }
end

script "get_conf_files" do
  interpreter "bash"
  user "root"
  cwd "/tmp"
  code <<-EOH
  cp clouddevinfra/cookbooks/clouddev/files/default/csvn/* /opt/csvn/data/conf/
  chown ubuntu:ubuntu /opt/csvn/data/conf/*.conf /opt/csvn/data/conf/server.*
  chmod -c 664 /opt/csvn/data/conf/*.conf /opt/csvn/data/conf/server.*
  EOH
  not_if { File.exists?("/opt/csvn/data/conf/csvn_logging.conf") && File.exists?("/opt/csvn/data/conf/csvn_main_httpd.conf") && File.exists?("/opt/csvn/data/conf/ctf_httpd.conf") && File.exists?("/opt/csvn/data/conf/httpd.conf") && File.exists?("/opt/csvn/data/conf/server.crt") && File.exists?("/opt/csvn/data/conf/server.key") }
end

cookbook_file "/opt/csvn/data/conf/httpd.conf" do
  source "csvn/httpd.conf"
  owner "ubuntu"
  action :create
end

cookbook_file "/opt/csvn/data/conf/svn_access_file" do
  source "csvn/svn_access_file"
  owner "ubuntu"
  action :create
end

execute "csvn_start" do
  command "/opt/csvn/bin/csvn-httpd restart"
  user "ubuntu"
end

