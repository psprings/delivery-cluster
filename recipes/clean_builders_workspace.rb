#
# Cookbook Name:: delivery-cluster
# Recipe:: clean_workspace
#
# Author:: Peter Springsteen (not <afiune@chef.io>)
#
# Copyright:: Copyright (c) 2016 Chef Software, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'delivery-cluster::_settings'

# Run clear_cache on all build nodes
machine_batch "#{node['delivery-cluster']['builders']['count']}-build-nodes" do
  1.upto(node['delivery-cluster']['builders']['count'].to_i) do |i|
    machine delivery_builder_hostname(i) do
      chef_server lazy { chef_server_config }
      add_machine_options(
        convergence_options: {
          chef_config_text: "encrypted_data_bag_secret File.join(File.dirname(__FILE__), 'encrypted_data_bag_secret')",
          ssl_verify_mode: :verify_none
        }
      )
      attributes lazy { builders_attributes }
      converge true
      action :converge
      run_list ['recipe[delivery_build::clear_workspace]']
    end
  end
end
