class ParentNameColumnForGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :parent_name, :string
    Group.find(:all, :conditions => [ 'parent_id IS NOT ?', nil ]).each do |group|
      start_name = group.full_name
      names = start_name.split "+"
      short_name = names.pop
      group.update_attribute :parent_name, "#{names.join "+"}"
      group.update_attribute :name, "#{short_name}"
    end
  end

  def self.down
    Group.find(:all, :conditions => [ 'parent_name IS NOT ?', nil ]).each do |group|
      group.update_attribute :name, "#{group.parent_name}+#{group.read_attribute :name}"
    end
    remove_column :groups, :parent_name, :string
  end
end
