class ContactsHasId < ActiveRecord::Migration
  def self.up
    add_column :contacts, :id, :primary_key, :auto_increment => true
    # re-saving each item creates reciprocal relationships where needed
    Contact.find( :all ).each(&:save)
  end

  def self.down
    remove_column :contacts, :id
  end
end
