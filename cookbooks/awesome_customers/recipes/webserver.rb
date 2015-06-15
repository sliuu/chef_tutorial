# Install Apache and configure its service.
include_recipe 'apache2::default'

# Create and enable your custom site.
web_app node['awesome_customers']['name'] do
  template "#{node['awesome_customers']['config']}.erb"
end

# Create the document root.
directory node['apache']['docroot_dir'] do
  recursive true
end

# Load the secrets file and the encrypted data bag item that holds the database password.
password_secret = Chef::EncryptedDataBagItem.load_secret("#{node['awesome_customers']['passwords']['secret_path']}")
user_password_data_bag_item = Chef::EncryptedDataBagItem.load('passwords', 'db_admin', password_secret)

# Write a default home page.
template "#{node['apache']['docroot_dir']}/index.php" do
  source 'index.php.erb'
  mode '0644'
  owner node['awesome_customers']['user']
  group node['awesome_customers']['group']
  variables({
    :database_password => user_password_data_bag_item['password']
  })
end

# Open port 80 to incoming traffic.
include_recipe 'iptables'
iptables_rule 'firewall_http'

# Install the mod_php5 Apache module.
include_recipe 'apache2::mod_php5'

# Install php-mysql.
package 'php-mysql' do
  action :install
  notifies :restart, 'service[apache2]'
end
