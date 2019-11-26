current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "anshuman"
client_key               "#{current_dir}/anshuman.pem"
validation_client_name   "remedyprime-validator"
validation_key           "#{current_dir}/remedyprime-validator.pem"
chef_server_url          "https://api.opscode.com/organizations/remedyprime"
cache_type               'BasicFile'
cache_options( :path => "#{ENV['HOME']}/.chef/checksums" )
cookbook_path            ["#{current_dir}/../cookbooks"]

knife[:aws_access_key_id]     = "AKIAJYSAQDHHLBLJT4EQ"
knife[:aws_secret_access_key] = "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"