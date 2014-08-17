`unison` Cookbook
=================

Chef provider for [Unison](http://www.cis.upenn.edu/~bcpierce/unison/). With
a simple and straight forward way to share a folder and install Unison on
CentOS/RHEL.

Provider
--------

### `unison_share`:

Used to share and syncronize a given folder with the network, basic usage:

```ruby
unison_share "stuff" do
  root "/media/stuff/"
end
```

Every node that recive this provider will update a data-bag (called `unison`)
that contain nodes that will be part of this group (or share-name). By the
default, the methode to share data is `ssh`. Other options:

* `root`: full-path of local shared folder;
* `user`: local user that will recieve Unison's preference files;
* `protocol`: protocl to share data;

The end result of this Chef provider is the ability to call Unison for a given
share on command-line:

```
$ unison stuff                                                                                                                <<<
Contacting server...
Connected [//drdb1//media/DRBD -> //drdb2//media/DRBD]
Looking for changes
  scanning sim.txt
  Waiting for changes from server
Reconciling changes
changed  <-?-> changed    small_file.txt
local        : changed file       modified on 2014-08-16 at  2:21:06  size 51        unknown permissions
drdb1        : changed file       modified on 2014-08-16 at  2:20:51  size 51        unknown permissions
         <---- new file   teste.txt
Propagating updates
UNISON 2.27.57 started propagating changes at 23:22:09 on 17 Aug 2014
[CONFLICT] Skipping small_file.txt
[BGN] Copying teste.txt from //drdb1//media/DRBD to /media/DRBD
[END] Copying teste.txt
UNISON 2.27.57 finished propagating changes at 23:22:09 on 17 Aug 2014
Saving synchronizer state
Synchronization complete  (1 item transferred, 1 skipped, 0 failures)
  skipped: small_file.txt
otaviof@drdb2:~$ cd /media/DRBD
```


Requirements
------------

### Packages
- `unison`: Needs unison package installed, dependencies will be handled via
  the package installer itself;

To deploy Unison, you may just include `unison::install` on node's `run_list`.

Attributes
----------

### `unison::install`

* `default[:unison][:user]`: User to save preference files. Default: `unison`;
* `default[:unison][:group]`: And following group. Default: `unison`;
* `default[:unison][:rpmname]`: Default: `unison227`;
* `default[:unison][:rpmversion]`: Default: `2.27.57-13.el6`;

Usage
-----

#### unison::default
TODO: Write usage instructions for each cookbook.

e.g.
Just include `unison` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[unison]"
  ]
}
```
