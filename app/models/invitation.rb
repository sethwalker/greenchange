class Invitation < Message
  belongs_to :invitable, :polymorphic => true
end
