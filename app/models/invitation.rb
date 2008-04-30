class Invitation < Message
  belongs_to :invitable, :polymorphic => true
  include Approvable
  attr_accessor :user_names
  polymorphic_attr :invitable, :as => [ :event, :group ]
  

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
