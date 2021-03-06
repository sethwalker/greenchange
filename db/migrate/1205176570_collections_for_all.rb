class CollectionsForAll < ActiveRecord::Migration
  def self.up
    User.find(:all).each &:initialize_collections
    Group.find(:all).each &:initialize_collections
  end

  def self.down
    Collection.find( :all, :conditions => ['user_id IS NOT ? OR group_id IS NOT ?', nil, nil ]).each(&:destroy)
  end
end
