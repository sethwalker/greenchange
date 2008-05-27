class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :network_event

  validates_presence_of :user_id
  validates_presence_of :network_event_id
end
