class InstallDemocracyInAction < ActiveRecord::Migration
  def self.up
    create_table :democracy_in_action_proxies do |t|
      t.integer :local_id
      t.string  :local_type
      t.integer :remote_key
      t.string  :remote_table
    end
  end
  def self.down
    drop_table :democracy_in_action_proxies
  end
end
