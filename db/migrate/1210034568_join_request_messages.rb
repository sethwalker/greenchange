class JoinRequestMessages < ActiveRecord::Migration
  def self.up
    remove_column :messages, :group_id
    add_column :messages, :approved_by_id, :integer
    reqs = MembershipRequest.find :all
    reqs.each do |req|
      JoinRequest.create :state => req.state, :sender => req.user, :body => req.message, :approved_by_id => req.approved_by_id, :requestable => req.group
    end
    reqs = ContactRequest.find :all
    reqs.each do |req|
      Invitation.create :state => req.state, :sender => req.user, :body => req.message, :invitable => req.user, :recipient_id => req.contact_id
    end
  end

  def self.down
    raise ActiveRecord::IrreversableMigration
    add_column :messages, :group_id, :integer
    remove_column :messages, :approved_by_id
  end
end
