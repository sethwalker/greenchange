#
# body          :text
# body_html     :text
# created_at    :datetime
# updated_at    :datetime
#

class Post < ActiveRecord::Base

  acts_as_rateable

  ## associations ############################################
  
  belongs_to :discussion, :counter_cache => true
  belongs_to :user

  ## attributes #############################################
  
  format_attribute :body
  attr_accessible :body
  
  ## validations ############################################

  validates_presence_of :discussion_id, :user_id, :body  

  ## methods ################################################

  def editable_by?(user)
    true
  end
  
  # used for default group, if present, to set for any embedded links
  def group_name
    discussion.page.group_name
  end

  after_create :notify_author
  def notify_author
    # NetworkEvent.create
    if page && page.created_by
      UserMailer.deliver_comment_posted(self) if page.created_by.receives_email_on('comments')
    end
  end

  def page
    discussion.try :page
  end
  
end
