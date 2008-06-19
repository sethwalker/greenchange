class Invitation < Message
  include Approvable
  belongs_to :invitable, :polymorphic => true
  validates_presence_of :invitable_id
  polymorphic_attr :invitable, :as => [ :event, :group, :contact ], :class_names => { :contact => 'User' }
  validate :no_preexisting_relationship
  

  def after_accepted
    if event?
      new_item = recipient.rsvps.find_or_create_by_event_id( event_id )
    end
    if group?
      new_item = recipient.memberships.find_or_create_by_group_id( group_id )
    end
    if contact?
      new_item = recipient.contact_relationships.find_or_create_by_contact_id( contact_id )
    end
    self.destroy if new_item && new_item.save
  end

  def no_preexisting_relationship
    unless recipient.nil?
      errors.add( :event, "already being attended by this member" ) if event? and recipient.events.include?( event )
      errors.add( :group, "already includes this member" ) if group? and recipient.groups.include?( group )
      errors.add( :recipients, "are already in your contacts" ) if contact? and recipient.contacts.include?( contact )
    end
  end

  def notify_recipient
    UserMailer.deliver_invitation_received(self) if recipient.receives_email_on('messages')
  end
end
