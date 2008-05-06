class JoinRequest < Message
  include Approvable
  belongs_to :approved_by, :class_name => 'User'
  belongs_to :requestable, :polymorphic => true
  validates_presence_of :requestable_id
  polymorphic_attr :requestable, :as => [ :event, :group ]

  def approval_allowed
    if group?
      approved_by && group.allows?(approved_by, :admin)
    elsif event?
      approved_by && event.allows?(approved_by, :admin)
    end
  end

  def after_approved
    if group?
      m = Membership.find_or_initialize_by_user_id_and_group_id(sender_id, group_id)
      m.role ||= 'member'
      m.save!
    end
    if event?
      ev = Rsvp.find_or_initialize_by_user_id_and_event_id(sender_id, event_id)
      ev.save!
    end
  end

  def recipient_required?
    false
  end
end
