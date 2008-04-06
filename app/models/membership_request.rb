class MembershipRequest < ActiveRecord::Base
  include Approvable

  belongs_to :user
  belongs_to :group
  belongs_to :approved_by, :class_name => 'User'

  attr_accessor :user_names
  def invitation?
    pending? && approved_by
  end
  def sender
    invitation? ? approved_by : user
  end

  def after_approved
    m = Membership.find_or_initialize_by_user_id_and_group_id(user_id, group_id)
    m.role ||= 'member'
    m.save!
  end

  def approval_allowed
    approved_by && group.allows?(approved_by, :admin)
  end

end
