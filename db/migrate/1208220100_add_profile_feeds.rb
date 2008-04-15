class AddProfileFeeds < ActiveRecord::Migration
  def self.up
    create_table "web_services" do |t|
      t.integer :profile_id
      t.string :web_service_type, :web_service_handle
    end
    
    create_table "languages" do |t|
      t.string :language
      t.integer :user_id, :profile_id
    end
    add_column :profiles, :political_party, :string

    add_index "web_services", ["profile_id"], :name => "web_services_profile_id_index"
  end



  def self.down
    remove_index "web_services", :name => "web_services_profile_id_index"

    remove_column :profiles, :political_party
    drop_table "languages"
    
    drop_table "web_services"
  end
end
