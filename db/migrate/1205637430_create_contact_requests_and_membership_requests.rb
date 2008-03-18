class CreateContactRequestsAndMembershipRequests < ActiveRecord::Migration
  def self.up
    create_table :contact_requests do |t|
      t.integer     :user_id
      t.integer     :contact_id
      t.string      :state
      t.text        :message
      t.timestamps
    end
    add_index :contact_requests, [:user_id, :contact_id, :state], :name => 'index_user_contact_state'
    add_index :contact_requests, [:contact_id, :user_id, :state], :name => 'index_contact_user_state'

    create_table :membership_requests do |t|
      t.integer     :user_id
      t.integer     :group_id
      t.string      :state
      t.integer     :approved_by
      t.text        :message
      t.timestamps
    end
    add_index :membership_requests, [:user_id, :group_id, :state], :name => 'index_user_group_state'
    add_index :membership_requests, [:group_id, :user_id, :state], :name => 'index_group_user_state'
  end

  def self.down
    drop_table :contact_requests
    drop_table :membership_requests
  end
end
