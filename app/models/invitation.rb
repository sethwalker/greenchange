class Invitation < Message
  include Approvable
  belongs_to :invitable, :polymorphic => true
  validates_presence_of :invitable_id
  polymorphic_attr :invitable, :as => [ :event, :group, :contact ], :class_names => { :contact => 'User' }
  

  def after_accepted
    if event?
      event.rsvps.create :user => recipient
    end
    if group?
      group.memberships.create :user => recipient
    end
    self.destroy
  end

end
