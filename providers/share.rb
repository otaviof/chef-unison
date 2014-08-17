#### Provider: unison_share ##################################################
#

action :share do
  # a new btsync databag if you don't have one yet
  if not Chef::DataBag.list.key?("unison")
    log "Creating initial data-bag for 'unison'"
    create_unison_databag()
  end

  # trying to update the data-bag straigh away, if an exception is raise then
  # we re-try creating the data-bag item
  begin
    log "Loading data-bag item for: #{@new_resource.share_name()}"
    update_unison_databag()
  rescue Net::HTTPServerException => e
    if e.response.code == "404" then
      log "New data-bag item for: #{@new_resource.share_name()}"
      create_unison_databag_item()
    else
      raise "ERROR: Received an HTTP Exception: #{e.response.code}"
    end
  end

  render_configuration()
  @new_resource.updated_by_last_action(true)
end

action :unshare do
  remove_node_from_unison_share()
  render_configuration()
  @new_resource.updated_by_last_action(true)
end

#### Routine Blocks ##########################################################
#

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
    item = Chef::DataBagItem.new()
    item.data_bag("unison")
    item.raw_data = {
      "id" => @new_resource.share_name(),
      "#{node.name()}" => {
        "root" => @new_resource.root(),
        "addr" => node.fqdn(),
        "user" => @new_resource.user(),
        "prot" => @new_resource.protocol(),
      }
    }
    item.save()
  rescue
    raise "Unable to create unison data bag item."
  end
end

def update_unison_databag()
  item = Chef::DataBagItem.load("unison", @new_resource.share_name())
  current_item = item.raw_data()
  current_item["#{node.name{}}"] = {
    "root" => @new_resource.root,
    "addr" => node.fqdn(),
    "user" => @new_resource.user,
    "prot" => @new_resource.protocol,
  }
  item.raw_data = current_item
  item.save()
end

def remove_node_from_unison_share()
  begin
    item = Chef::DataBagItem.load("unison", @new_resource.share_name())
    current_item = item.raw_data()
    current_item.delete("#{node.name()}")
    item.raw_data = current_item
    item.save()
  rescue
    raise "Can't remove current node from unison share."
  end
end

def load_data_bag_hash()
  begin
    bag = Chef::DataBagItem.load("unison", @new_resource.share_name())
    raw_data = bag.raw_data().to_hash()
  rescue
    raise "Can't load raw contents from data bag 'unison'"
  end
  return raw_data
end

def unison_share_root_list()
  root_list = Array.new()
  item = load_data_bag_hash()
  item.each() do |key, value|
    next if value.kind_of?(String)
    # checking each "peer" for the current share, if it's local, only the
    # direcotry will be informed as "root"
    if key == node.name()
      root_list << value['root']
    else
      root_list << "#{value['prot']}://#{value['user']}@#{value['addr']}/#{value['root']}"
    end
  end
  return root_list
end

def render_configuration()
  home_folder = Dir.home(node[:unison][:user])

  directory "#{home_folder}/.unison" do
    user node[:unison][:user]
    group node[:unison][:group]
    action :create
  end

  template "#{home_folder}/.unison/#{@new_resource.share_name()}.prf" do
    cookbook "unison"
    source "unison_share.prf.erb"
    owner node[:unison][:user]
    group node[:unison][:group]
    variables(
      { :unison =>
        { :root_list => unison_share_root_list() }
      }
    )
  end
end

# EOF
