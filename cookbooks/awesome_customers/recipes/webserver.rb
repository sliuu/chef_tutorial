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

# Write a default home page.
file "#{node['apache']['docroot_dir']}/index.php" do
  content '<html>This is a placeholder</html>'
  mode '0644'
  owner node['awesome_customers']['user']
  group node['awesome_customers']['group']
end

# Open port 80 to incoming traffic.
include_recipe 'iptables'
iptables_rule 'firewall_http'
