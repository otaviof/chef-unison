#### Resource: unison::share #################################################
#

attribute :cookbook,
  :kind_of => String,
  :default => 'unison'

attribute :share_name,
  :kind_of => String,
  :default => node[:hostname].downcase

# EOF
