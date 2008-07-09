class AddDeltaToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :searchable, :boolean, :default => 1
    add_column :users, :delta, :boolean
  end

  def self.down
    remove_column :users, :delta
    remove_column :users, :searchable
  end
end
