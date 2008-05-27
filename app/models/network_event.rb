class NetworkEvent < ActiveRecord::Base
  belongs_to :modified, :polymorphic => true
  belongs_to :user

  validates_presence_of :modified_id
  validates_presence_of :user_id
  validates_presence_of :action

  after_create :create_notifications

  def send_notifications(recipients)
    @notices = Notification.create recipients.map{ |user| { :user => user, :network_event => self} }
  end

  def create_notifications
    send_notifications(modified.watchers)
  end

end
