class Invitation < Message
  belongs_to :invitable, :polymorphic => true
  include Approvable

  def after_accepted
    if self.invitable < Event
      self.invitable.attendees.create :user => recipient
    end
  end

end