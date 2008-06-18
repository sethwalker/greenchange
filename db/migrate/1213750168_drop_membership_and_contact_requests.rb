class DropMembershipAndContactRequests < ActiveRecord::Migration
  def self.up
    drop_table :membership_requests
    drop_table :contact_requests
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration, "these tables are gone, baby"
  end
end
