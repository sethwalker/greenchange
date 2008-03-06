class Collecting < ActiveRecord::Base
  belongs_to :collection
  belongs_to :collectable, :polymorphic => true
end
