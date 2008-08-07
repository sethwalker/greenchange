class FeaturedMembersAndGroups < ActiveRecord::Migration
  def self.up
    add_column :users, 'featured', :boolean
    add_column :groups, 'featured', :boolean
  end

  def self.down
    remove_column :groups, 'featured'
    remove_column :users, 'featured'
  end
end
