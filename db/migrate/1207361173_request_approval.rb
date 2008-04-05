class RequestApproval < ActiveRecord::Migration
  def self.up
    add_column :membership_requests, :approved_by_id, :integer
    add_column :contact_requests, :approved_by_id, :integer
    remove_column :membership_requests, :approved_by
  end

  def self.down
    remove_column :contact_requests, :approved_by_id
    remove_column :membership_requests, :approved_by_id
  end
end
