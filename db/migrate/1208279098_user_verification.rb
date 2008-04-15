class UserVerification < ActiveRecord::Migration
  def self.up
    add_column :users, :activation_code, :string, :limit => 40
    add_column :users, :activated_at, :datetime
    add_column :users, :enabled, :boolean,  :default => true
    add_column :users, :identity_url, :string
  end

  def self.down
    remove_column :users, :identity_url
    remove_column :users, :enabled
    remove_column :users, :activated_at
    remove_column :users, :activation_code
  end
end
