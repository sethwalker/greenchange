class SubscribedPages < ActiveRecord::Migration
  def self.up
    add_column :pages, 'subscription_id', :integer
  end

  def self.down
    remove_column :pages, 'subscription_id'
  end
end
