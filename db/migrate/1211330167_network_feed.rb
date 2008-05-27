class NetworkFeed < ActiveRecord::Migration
  def self.up
    create_table "network_events" do |t|
      t.integer "user_id" #who created it

      t.string "modified_type"
      t.integer "modified_id"

      t.string "action" #create, update, delete

      t.timestamps
    end

    add_index "network_events", ["modified_type", "modified_id"], :name => "index_on_modified"
    add_index "network_events", "user_id", :name => "index_on_user_id"

    create_table "notifications" do |t|
      t.integer "network_event_id"
      t.integer "user_id" #who got notified
      t.string "status", :default => "new"
    end

    add_index "notifications", ["user_id", "status"], :name => "index_on_user_id_and_status"

    NetworkEvent.record_timestamps = false
    Page.find(:all).each do |page|
      if page.updated_at == page.created_at
        NetworkEvent.create :modified => page, :user => page.created_by, :created_at => page.created_at, :action => 'create'
      else
        NetworkEvent.create :modified => page, :user => page.updated_by, :created_at => page.updated_at, :action => 'update'
      end
    end
    NetworkEvent.record_timestamps = true
=begin
    User.find(:all).each do |user|
      pages = Page.in_network(user).allowed(user).find(:all, :order => "updated_at DESC", :limit => 40)
      pages.each do |page|

        network_event = NetworkEvent.find_or_initialize_by_user_id_and_affected_id
        network_event.save
      end
    end
=end
  end


  def self.down
    drop_table "notifications"
    drop_table "network_events"
  end
end
