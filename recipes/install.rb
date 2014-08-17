#### Recipe: unison::install #################################################
#

package node[:unison][:rpmname] do
  version node[:unison][:rpmversion]
  action :install
end

service "unison" do
  supports :restart => true, :start => true, :stop => true, :reload => true
  action :nothing
end

# EOF
