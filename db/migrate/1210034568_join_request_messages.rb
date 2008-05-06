class JoinRequestMessages < ActiveRecord::Migration
  def self.up
    remove_column :messages, :group_id
    add_column :messages, :approved_by_id, :integer
    reqs = MembershipRequest.find :all
    reqs.each do |req|
      JoinRequest.create :state => req.state, :sender => req.user, :body => req.message, :approved_by_id => req.approved_by_id, :requestable => req.group
    end
  end

  def self.down
    add_column :messages, :group_id, :integer
    remove_column :messages, :approved_by_id
    raise ActiveRecord::IrreversableMigration
  end
end
