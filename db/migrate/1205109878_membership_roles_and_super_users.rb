class MembershipRolesAndSuperUsers < ActiveRecord::Migration
  def self.up
    add_column :memberships,    :role,          :string,    :limit => 20, :default => 'member'
    add_column :users,          :superuser,     :boolean,   :default => 0
  end

  def self.down
    remove_column :users,       :superuser
    remove_column :memberships, :role
  end
end
