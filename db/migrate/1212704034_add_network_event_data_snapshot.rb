class AddNetworkEventDataSnapshot < ActiveRecord::Migration
  def self.up
    add_column :network_events, :data_snapshot, :text
  end

  def self.down
    remove_column :network_events, :data_snapshot
  end
end
