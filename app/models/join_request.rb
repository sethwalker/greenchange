class JoinRequest < Message
  include Approvable
  belongs_to :approved_by, :class_name => 'User'
  belongs_to :requestable, :polymorphic => true
  validates_presence_of :requestable_id
  polymorphic_attr :requestable, :as => [ :event, :group ]

  has_finder :by_group, lambda { |*groups| groups.flatten.any? ?  {:conditions => [ "messages.requestable_id in (?) and messages.requestable_type = 'Group'", groups ] }: {} }
  has_finder :by_event, lambda { |*events| events.any? ? {:conditions => [ "messages.requestable_id in (?) and messages.requestable_type = 'Event'", events ] }: {} }

  has_finder :to, lambda {|*users| 
    if users.flatten.any? 
      groups = users.map(&:groups_administering).flatten
      if groups.any? 
        {:conditions => [ "messages.requestable_id in (?) and messages.requestable_type = 'Group'", groups ] }
      else
        {:conditions => [ '?', false ]}
      end
    else
      {}
    end
  }

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

  def allows?( user, action )
    return true if requestable_id? and user.may?( :admin, requestable )
    super
  end
end
