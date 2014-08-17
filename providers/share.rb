#### Provider: unison_share ##################################################
#

actions :share, :unshare
default_action :share

action :share do
#
# {
#   :share_name => {
#     :node_name => {
#       :root => '/var/tmp',
#       :addr => node[:fqdn],
#       :user => node[:unison][:user]
#       :prot => 'ssh'
#     }
#   }
# }
#
  # a new btsync databag if you don't have one yet
  if not Chef::DataBag.list.key?("unison")
    log "Creating initial data-bag for 'unison'"
    create_unison_databag()
  end

  # trying to update the data-bag straigh away, if an exception is raise then
  # we re-try creating the data-bag item
  begin
    log "Loading data-bag item for: #{new_resource.share_name()}"
    update_unison_databag()
  rescue Net::HTTPServerException => e
    if e.response.code == "404" then
      log "New data-bag item for: #{new_resource.share_name()}"
      create_unison_databag_item()
    else
      raise "ERROR: Received an HTTPException of type #{e.response.code}"
    end
  end

end

def create_unison_databag()
  begin
    new_databag = Chef::DataBag.new()
    new_databag.name("unison")
    new_databag.save()
  rescue
    raise "Unable to create new databag."
  end
end

def create_unison_databag_item()
  begin
    item = Chef::DataBagItem.new
    item.data_bag("unison")
    item.raw_data = {
      "id" => new_resource.share_name,
      "#{node.name()}" => {
        "root" => new_resource.root,
        "addr" => node.fqdn(),
        "user" => new_resource.user,
        "prot" => new_resource.protocol,
      }
    }
    item.save()
  rescue
    raise "Unable to create unison data bag item."
  end
end

def update_unison_databag()
  item = load_data_bag_hash()
  item["#{node.name{}}"] = {
    "root" => new_resource.root,
    "addr" => node.fqdn(),
    "user" => new_resource.user,
    "prot" => new_resource.protocol,
  }
  item.save()
end

def load_data_bag_hash()
  begin
    bag = Chef::DataBagItem.load("unison", new_resource.share_name())
    raw_data = bag.raw_data().to_hash()
  rescue
    raise "Can't load raw contents from data bag 'unison'"
  end
  return raw_data
end

# EOF
