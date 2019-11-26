#
# Cookbook Name:: s3backup
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
package "s3cmd" do
	action [:install]
end

cookbook_file "/root/.s3cfg" do
  source ".s3cfg"
end

cookbook_file "/home/ubuntu/.s3cfg" do
  source ".s3cfg"
end

cookbook_file "/usr/bin/s3_backup_dir.sh" do
  source "s3_backup_dir.sh"
  mode "755"
end

if node[:s3backup]
  node[:s3backup].each do |name, config|
  	if config[:frequency] == "daily"
  		cron "Chron_#{name}" do
  			hour "1"
  			minute "0"
  			command "s3_backup_dir.sh #{name} #{config[:folder]} daily"
        mailto "support@hashedin.com"
  		end
  	elsif config[:frequency] == "weekly"
      cron "Chron_#{name}" do
        weekday "0"
        hour "1"
        minute "0"
        command "s3_backup_dir.sh #{name} #{config[:folder]} weekly"
        mailto "support@hashedin.com"
      end
    elsif config[:frequency] == "monthly"
      cron "Chron_#{name}" do
        hour "1"
        minute "0"
        command "s3_backup_dir.sh #{name} #{config[:folder]} monthly"
        mailto "support@hashedin.com"
      end
  	end
  end
end
