class GroupLocations < ActiveRecord::Migration
  def self.up
    add_column :locations, :group_id, :integer
    add_index :locations, :group_id, :name => "index_on_group_id"
  end

  def self.down
    remove_column :locations, :group_id
  end
end
