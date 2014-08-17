#### Resource: unison_share #################################################
#

actions :share, :unshare
default_action :share

attribute :cookbook,
  :kind_of => String,
  :default => 'unison'

attribute :share_name,
  :kind_of => String,
  :name_attribute => true,
  :required => true

attribute :root,
  :kind_of => String,
  :required => true

attribute :user,
  :kind_of => String,
  :default => node[:unison][:user]

attribute :protocol,
  :kind_of => String,
  :default => "ssh"

# EOF
