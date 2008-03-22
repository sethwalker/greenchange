class IndexMembershipsUniquely < ActiveRecord::Migration
  def self.up
    remove_index :memberships, :name => "index_memberships"
    add_index :memberships, ["group_id", "user_id", "role"], :name => "index_group_user_role", :unique => true
    add_index :memberships, ["user_id", "group_id", "role"], :name => "index_user_group_role", :unique => true
  end

  def self.down
    remove_index :memberships, :name => "index_user_group_role"
    remove_index :memberships, :name => "index_group_user_role"
    add_index "memberships", ["group_id", "user_id", "page_id"], :name => "index_memberships"
  end
end
