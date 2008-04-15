class Invitation < Message
  belongs_to :invitable, :polymorphic => true

  def after_accepted
    if self.invitable < Event
      event.attendees.create :user => recipient
  end
end
