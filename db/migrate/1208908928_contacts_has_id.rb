class ContactsHasId < ActiveRecord::Migration
  def self.up
    if ActiveRecord::Base.connection.adapter_name == 'SQLite'
      contacts = Contact.find(:all)
      drop_table :contacts
      create_table :contacts, :force => true do |t|
        t.integer "user_id"
        t.integer "contact_id"
      end
      add_index "contacts", ["contact_id", "user_id"], :name => "index_contacts"
      Contact.reset_column_information
      contacts.each(&:save)
    else
      add_column :contacts, :id, :primary_key, :auto_increment => true
      # re-saving each item creates reciprocal relationships where needed
      Contact.find( :all ).each(&:save)
    end
  end

  def self.down
    remove_column :contacts, :id
  end
end
