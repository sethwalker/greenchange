class ChangeSearchableDefault < ActiveRecord::Migration
  def self.up
    change_column :users, :searchable, :boolean, :default => false
  end

  def self.down
    change_column :users, :searchable, :boolean, :default => true
  end
end
