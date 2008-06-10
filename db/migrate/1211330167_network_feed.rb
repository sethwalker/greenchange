class NetworkFeed < ActiveRecord::Migration
  def self.up
    create_table "network_events" do |t|
      t.integer "user_id" #who created it

      t.string "modified_type"
      t.integer "modified_id"

      t.string "action" #create, update, delete

      t.text "data_snapshot"
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
      if (page.updated_at == page.created_at) && page.created_by
        NetworkEvent.create! :modified => page, :action => 'create', :user => page.created_by, :recipients => watchers(page), :data_snapshot => {:page => page, :page_created_by => page.created_by}, :user => page.created_by
      elsif page.created_by && page.updated_by
        NetworkEvent.create! :modified => page, :action => 'update', :user => page.updated_by, :recipients => watchers(page), :data_snapshot => {:page => page, :page_created_by => page.created_by, :page_updated_by => page.updated_by}, :user => page.updated_by
      end
    end
    NetworkEvent.record_timestamps = true
  end


  def self.down
    drop_table "notifications"
    drop_table "network_events"
  end

  def self.watchers(page)
    ( [ page.created_by ] << page.created_by.try(:contacts) << page.group.try(:members ) ).flatten.compact.uniq
  end
end
