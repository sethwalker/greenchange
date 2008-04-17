class Invitation < Message
  belongs_to :invitable, :polymorphic => true
  include Approvable
  attr_accessor :user_names

  def after_accepted
    if event?
      self.invitable.attendees.create :user => recipient
    end
  end

  def event?
    invitable.is_a?(Event)
  end

  def group?
    invitable.is_a?(Group)
  end

  def event
    event? ? self.invitable : nil
  end

  def group 
    group? ? self.invitable : nil
  end
end
