class DemocracyInActionProxyNames < ActiveRecord::Migration
  def self.up
    add_column :democracy_in_action_proxies, :name, :string
    add_index :democracy_in_action_proxies, :remote_table, :name => 'index_proxies_on_remote_table'
    add_index :democracy_in_action_proxies, :name, :name => 'index_proxies_on_name'
  end

  def self.down
    remove_index :democracy_in_action_proxies, :name => 'index_proxies_on_name'
    remove_index :democracy_in_action_proxies, :name => 'index_proxies_on_remote_table'
    remove_column :democracy_in_action_proxies, :name
  end
end
